-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

newTalent{
	name = "Throw Bomb",
	type = {"spell/explosives", 1},
	require = spells_req1,
	points = 5,
	mana = 5,
	cooldown = 4,
	range = function(self, t)
		return math.ceil(5 + self:getDex(6))
	end,
	radius = function(self, t)
		return util.bound(1+self:getTalentLevelRaw(self.T_EXPLOSION_EXPERT), 1, 6)
	end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo then return end
		-- Using friendlyfire, although this could affect escorts etc.
		local friendlyfire = true
		local prot = self:getTalentLevelRaw(self.T_ALCHEMIST_PROTECTION) * 20
		if prot > 0 then
			friendlyfire = 100 - prot
		end
		return {type="ball", range=self:getTalentRange(t)+(ammo and ammo.alchemist_bomb and ammo.alchemist_bomb.range or 0), radius=self:getTalentRadius(t), friendlyfire=friendlyfire, talent=t}
	end,
	tactical = { ATTACKAREA = function(self, t, target)
		if self:isTalentActive(self.T_ACID_INFUSION) then return { ACID = 2 }
		elseif self:isTalentActive(self.T_LIGHTNING_INFUSION) then return { LIGHTNING = 2 }
		elseif self:isTalentActive(self.T_FROST_INFUSION) then return { COLD = 2 }
		else return { FIRE = 2 }
		end
	end },
	computeDamage = function(self, t, ammo)
		local inc_dam = 0
		local damtype = DamageType.FIRE
		local particle = "ball_fire"
		local acidi = self:getTalentFromId(Talents.T_ACID_INFUSION)
		local lightningi = self:getTalentFromId(Talents.T_LIGHTNING_INFUSION)
		local frosti = self:getTalentFromId(Talents.T_FROST_INFUSION)
		local fireinf = self:getTalentFromId(Talents.T_FIRE_INFUSION)
		if self:isTalentActive(self.T_ACID_INFUSION) then inc_dam = acidi.getIncrease(self,acidi); damtype = DamageType.ACID_BLIND; particle = "ball_acid"
		elseif self:isTalentActive(self.T_LIGHTNING_INFUSION) then inc_dam = lightningi.getIncrease(self,lightningi); damtype = DamageType.LIGHTNING_DAZE; particle = "ball_lightning"
		elseif self:isTalentActive(self.T_FROST_INFUSION) then inc_dam = frosti.getIncrease(self,frosti); damtype = DamageType.ICE; particle = "ball_ice"
		else inc_dam = fireinf.getIncrease(self,fireinf); damtype = self:knowTalent(self.T_FIRE_INFUSION) and DamageType.FIREBURN or DamageType.FIRE
		end
		inc_dam = inc_dam + (ammo.alchemist_bomb and ammo.alchemist_bomb.power or 0) / 100
		local dam = self:combatTalentSpellDamage(t, 15, 150, ((ammo.alchemist_power or 0) + self:combatSpellpower()) / 2)
		dam = dam * (1 + inc_dam)
		return dam, damtype, particle
	end,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo then
			game.logPlayer(self, "You need to ready alchemist gems in your quiver.")
			return
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		ammo = self:removeObject(self:getInven("QUIVER"), 1)
		if not ammo then return end

		local dam, damtype, particle = t.computeDamage(self, t, ammo)
		dam = self:spellCrit(dam)
		local prot = self:getTalentLevelRaw(self.T_ALCHEMIST_PROTECTION) * 0.2
		local golem
		if self.alchemy_golem then
			golem = game.level:hasEntity(self.alchemy_golem) and self.alchemy_golem or nil
		end
		local dam_done = 0

		-- Compare theorical AOE zone with actual zone and adjust damage accordingly
		if self:knowTalent(self.T_EXPLOSION_EXPERT) then
			local theorical_nb = ({ 9, 25, 45, 77, 109, 145 })[tg.radius] or 145
			local nb = 0
			local grids = self:project(tg, x, y, function(tx, ty) end)
			for px, ys in pairs(grids) do for py, _ in pairs(ys) do nb = nb + 1 end end
			nb = theorical_nb - nb
			if nb > 0 then
				local mult = math.log10(nb) / (6 - math.min(self:getTalentLevelRaw(self.T_EXPLOSION_EXPERT), 5))
				print("Adjusting explosion damage to account for ", nb, " lost tiles => ", mult * 100)
				dam = dam + dam * mult
			end
		end

		local tmp = {}
		local grids = self:project(tg, x, y, function(tx, ty)
			local d = dam
			-- Protect yourself
			if tx == self.x and ty == self.y then d = dam * (1 - prot) end
			-- Protect the golem
			if golem and tx == golem.x and ty == golem.y then d = dam * (1 - prot) end
			if d == 0 then return end

			local target = game.level.map(tx, ty, Map.ACTOR)
			dam_done = dam_done + DamageType:get(damtype).projector(self, tx, ty, damtype, d, tmp)
			if ammo.alchemist_bomb and ammo.alchemist_bomb.splash then
				DamageType:get(DamageType[ammo.alchemist_bomb.splash.type]).projector(self, tx, ty, DamageType[ammo.alchemist_bomb.splash.type], ammo.alchemist_bomb.splash.dam)
			end
			if not target then return end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.stun and rng.percent(ammo.alchemist_bomb.stun.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, ammo.alchemist_bomb.stun.dur, {apply_power=self:combatSpellpower()})
			end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.daze and rng.percent(ammo.alchemist_bomb.daze.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, ammo.alchemist_bomb.daze.dur, {apply_power=self:combatSpellpower()})
			end
		end)

		if ammo.alchemist_bomb and ammo.alchemist_bomb.leech then self:heal(math.min(self.max_life * ammo.alchemist_bomb.leech / 100, dam_done)) end

		local _ _, x, y = self:canProject(tg, x, y)
		-- Lightning ball gets a special treatment to make it look neat
		if particle == "ball_lightning" then
			local sradius = (tg.radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
			local nb_forks = 16
			local angle_diff = 360 / nb_forks
			for i = 0, nb_forks - 1 do
				local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
				local tx = x + math.floor(math.cos(a) * tg.radius)
				local ty = y + math.floor(math.sin(a) * tg.radius)
				game.level.map:particleEmitter(x, y, tg.radius, "lightning", {radius=tg.radius, grids=grids, tx=tx-x, ty=ty-y, nb_particles=25, life=8})
			end
		else
			game.level.map:particleEmitter(x, y, tg.radius, particle, {radius=tg.radius, grids=grids, tx=x, ty=y})
		end

		if ammo.alchemist_bomb and ammo.alchemist_bomb.mana then self:incMana(ammo.alchemist_bomb.mana) end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		local dam, damtype = 1, DamageType.FIRE
		if ammo then dam, damtype = t.computeDamage(self, t, ammo) end
		dam = damDesc(self, damtype, dam)
		return ([[Imbue an alchemist gem with an explosive charge of mana and throw it.
		The gem will explode for %0.2f %s damage.
		Each kind of gem will also provide a specific effect.
		The damage will improve with better gems and with your Spellpower; the range, with your Dexterity.]]):format(dam, DamageType:get(damtype).name)
	end,
}

newTalent{
	name = "Alchemist Protection",
	type = {"spell/explosives", 2},
	require = spells_req2,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 3
		self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 3
		self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 3
		self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) + 3
	end,
	on_unlearn = function(self, t)
		self.resists[DamageType.FIRE] = self.resists[DamageType.FIRE] - 3
		self.resists[DamageType.COLD] = self.resists[DamageType.COLD] - 3
		self.resists[DamageType.LIGHTNING] = self.resists[DamageType.LIGHTNING] - 3
		self.resists[DamageType.ACID] = self.resists[DamageType.ACID] - 3
	end,
	info = function(self, t)
		return ([[Improves your resistance (and your golem's) against the elemental damage of your own bombs by %d%%, and against external elemental damage by %d%%.
		At talent level 5 it also protects you against all side effects of your bombs.]]):
		format(self:getTalentLevelRaw(t) * 20, self:getTalentLevelRaw(t) * 3)
	end,
}

newTalent{
	name = "Explosion Expert",
	type = {"spell/explosives", 3},
	require = spells_req3,
	mode = "passive",
	points = 5,
	info = function(self, t)
		local theorical_nb = ({ 9, 25, 45, 77, 109, 145 })[1 + self:getTalentLevelRaw(self.T_EXPLOSION_EXPERT)] or 145
		local min = 1
		local min = (math.log10(min) / (6 - self:getTalentLevelRaw(self.T_EXPLOSION_EXPERT)))
		local max = theorical_nb
		local max = (math.log10(max) / (6 - self:getTalentLevelRaw(self.T_EXPLOSION_EXPERT)))

		return ([[Your alchemist bombs now affect a radius of %d around them.
		Increases explosion damage by %d%% (one tile less than the full effect) to %d%% (explosion concentrated on only 1 tile)]]):format(self:getTalentLevelRaw(t), min*100, max*100)
	end,
}

newTalent{
	name = "Shockwave Bomb",
	type = {"spell/explosives",4},
	require = spells_req4,
	points = 5,
	mana = 32,
	cooldown = 10,
	range = function(self, t)
		return math.ceil(5 + self:getDex(6))
	end,
	radius = 2,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		-- Using friendlyfire, although this could affect escorts etc.
		local friendlyfire = true
		local prot = self:getTalentLevelRaw(self.T_ALCHEMIST_PROTECTION) * 20
		if prot > 0 then
			friendlyfire = 100 - prot
		end
		return {type="ball", range=self:getTalentRange(t)+(ammo and ammo.alchemist_bomb and ammo.alchemist_bomb.range or 0), radius=self:getTalentRadius(t), friendlyfire=friendlyfire, talent=t}
	end,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { knockback = 2 } },
	computeDamage = function(self, t, ammo)
		local inc_dam = 0
		local damtype = DamageType.SPELLKNOCKBACK
		local particle = "ball_fire"
		inc_dam = (ammo.alchemist_bomb and ammo.alchemist_bomb.power or 0) / 100
		local dam = self:combatTalentSpellDamage(t, 15, 120, ((ammo.alchemist_power or 0) + self:combatSpellpower()) / 2)
		dam = dam * (1 + inc_dam)
		return dam, damtype, particle
	end,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo or ammo:getNumber() < 2 then
			game.logPlayer(self, "You need to ready at least two alchemist gems in your quiver.")
			return
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:removeObject(self:getInven("QUIVER"), 1)
		ammo = self:removeObject(self:getInven("QUIVER"), 1)
		if not ammo then return end

		local dam, damtype, particle = t.computeDamage(self, t, ammo)
		dam = self:spellCrit(dam)
		local prot = self:getTalentLevelRaw(self.T_ALCHEMIST_PROTECTION) * 0.2
		local golem
		if self.alchemy_golem then
			golem = game.level:hasEntity(self.alchemy_golem) and self.alchemy_golem or nil
		end
		local dam_done = 0

		local tmp = {}
		local grids = self:project(tg, x, y, function(tx, ty)
			local d = dam
			-- Protect yourself
			if tx == self.x and ty == self.y then d = dam * (1 - prot) end
			-- Protect the golem
			if golem and tx == golem.x and ty == golem.y then d = dam * (1 - prot) end
			if d == 0 then return end

			local target = game.level.map(tx, ty, Map.ACTOR)
			dam_done = dam_done + DamageType:get(damtype).projector(self, tx, ty, damtype, d, tmp)
			if ammo.alchemist_bomb and ammo.alchemist_bomb.splash then
				DamageType:get(DamageType[ammo.alchemist_bomb.splash.type]).projector(self, tx, ty, DamageType[ammo.alchemist_bomb.splash.type], ammo.alchemist_bomb.splash.dam)
			end
			if not target then return end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.stun and rng.percent(ammo.alchemist_bomb.stun.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, ammo.alchemist_bomb.stun.dur, {apply_power=self:combatSpellpower()})
			end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.daze and rng.percent(ammo.alchemist_bomb.daze.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, ammo.alchemist_bomb.daze.dur, {apply_power=self:combatSpellpower()})
			end
		end)

		if ammo.alchemist_bomb and ammo.alchemist_bomb.leech then self:heal(math.min(self.max_life * ammo.alchemist_bomb.leech / 100, dam_done)) end

		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, particle, {radius=tg.radius, grids=grids, tx=x, ty=y})

		if ammo.alchemist_bomb and ammo.alchemist_bomb.mana then self:incMana(ammo.alchemist_bomb.mana) end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		local dam, damtype = 1
		if ammo then dam = t.computeDamage(self, t, ammo) end
		dam = damDesc(self, DamageType.PHYSICAL, dam)
		return ([[Crush together two alchemist gems, making them extremely unstable.
		You then throw them to a target area, where they explode on impact dealing %0.2f physical damage and knocking back any creatures in the blast radius.
		Each kind of gem will also provide a specific effect.
		The damage will improve with better gems and with your Spellpower; the range, with your Dexterity.]]):format(dam)
	end,
}
