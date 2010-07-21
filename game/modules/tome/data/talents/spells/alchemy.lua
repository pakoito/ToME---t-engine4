-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
		return math.ceil(5 + self:getDex(12))
	end,
	computeDamage = function(self, t, ammo)
		local inc_dam = 0
		local damtype = DamageType.FIRE
		local particle = "ball_fire"
		if self:isTalentActive(self.T_ACID_INFUSION) then inc_dam = self:getTalentLevel(self.T_ACID_INFUSION) * 0.05; damtype = DamageType.ACID; particle = "ball_acid"
		elseif self:isTalentActive(self.T_LIGHTNING_INFUSION) then inc_dam = self:getTalentLevel(self.T_LIGHTNING_INFUSION) * 0.05; damtype = DamageType.LIGHTNING; particle = "ball_lightning"
		elseif self:isTalentActive(self.T_FROST_INFUSION) then inc_dam = self:getTalentLevel(self.T_FROST_INFUSION) * 0.05; damtype = DamageType.ICE; particle = "ball_ice"
		else inc_dam = self:getTalentLevel(self.T_FIRE_INFUSION) * 0.05 + (ammo.alchemist_bomb.power or 0) / 100
		end
		local dam = self:combatTalentSpellDamage(t, 15, 150, (ammo.alchemist_power + self:combatSpellpower()) / 2)
		dam = dam * (1 + inc_dam)
		return dam, damtype, particle
	end,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo then
			game.logPlayer(self, "You need to ready alchemist gems in your quiver.")
			return
		end

		local tg = {type="ball", range=self:getTalentRange(t)+(ammo.alchemist_bomb.range or 0), radius=1+self:getTalentLevelRaw(self.T_EXPLOSION_EXPERT), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		ammo = self:removeObject(self:getInven("QUIVER"), 1)
		if not ammo then return end

		local dam, damtype, particle = t.computeDamage(self, t, ammo)
		local prot = self:getTalentLevelRaw(self.T_ALCHEMIST_PROTECTION) * 0.2
		local golem = game.level:hasEntity(self.alchemy_golem) and self.alchemy_golem or nil
		local dam_done = 0

		local grids = self:project(tg, x, y, function(tx, ty)
			local d = dam
			-- Protect yourself
			if tx == self.x and ty == self.y then d = dam * (1 - prot) end
			-- Protect the golem
			if golem and tx == golem.x and ty == golem.y then d = dam * (1 - prot) end

			DamageType:get(damtype).projector(self, tx, ty, damtype, self:spellCrit(d))
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			if ammo.alchemist_bomb.splash then
				DamageType:get(DamageType[ammo.alchemist_bomb.splash.type]).projector(self, tx, ty, DamageType[ammo.alchemist_bomb.splash.type], ammo.alchemist_bomb.splash.dam)
			end
			if ammo.alchemist_bomb.stun and rng.percent(ammo.alchemist_bomb.stun.chance) and target:checkHit(self:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 5) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, ammo.alchemist_bomb.stun.dur, {})
			end
			if ammo.alchemist_bomb.daze and rng.percent(ammo.alchemist_bomb.daze.chance) and target:checkHit(self:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 5) and target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, ammo.alchemist_bomb.daze.dur, {})
			end
		end)

		if ammo.alchemist_bomb.leech then self:heal(math.min(self.max_life * ammo.alchemist_bomb.leech / 100, dam_done)) end

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

		if ammo.alchemist_bomb.mana then self:incMana(ammo.alchemist_bomb.mana) end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		local dam, damtype = 1, DamageType.FIRE
		if ammo then dam, damtype = t.computeDamage(self, t, ammo) end
		return ([[Imbue an alchemist gem with an explosive charge of mana and throw it.
		The gem will explode for %0.2f %s damage.
		The damage will improve with better gems and Magic stat and the range with your dexterity.]]):format(dam, DamageType:get(damtype).name)
	end,
}

newTalent{
	name = "Explosion Expert",
	type = {"spell/explosives", 2},
	require = spells_req2,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[Your alchemist bombs now affect a radius of %d around them.]]):format(self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Alchemist Protection",
	type = {"spell/explosives", 3},
	require = spells_req3,
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
		return ([[Improves your resistance against your own bombs elemental damage by %d%% and against external one by %d%%.]]):
		format(self:getTalentLevelRaw(t) * 20, self:getTalentLevelRaw(t) * 3)
	end,
}

newTalent{
	name = "Stone Touch",
	type = {"spell/explosives",4},
	require = spells_req4,
	points = 5,
	mana = 80,
	cooldown = 15,
	range = function(self, t)
		if self:getTalentLevel(t) < 3 then return 1
		else return math.floor(self:getTalentLevel(t)) end
	end,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		if self:getTalentLevel(t) >= 3 then tg.type = "beam" end
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end

			if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 10) and target:canBe("stone") and target:canBe("instakill") then
				target:setEffect(target.EFF_STONED, math.floor((3 + self:getTalentLevel(t)) / 1.5), {})
				game.level.map:particleEmitter(tx, ty, 1, "archery")
			end
		end)
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[Touch your foe and turn it into stone for %d turns.
		Stoned creatures are unable to act or regen life and are very brittle.
		If a stoned creature if hit by an attack that deals more than 30%% of its life it will shatter and be destroyed.
		Stoned creatures are highly resistant to fire and lightning and somewhat resistant to physical attacks.
		At level 3 it will become a beam.]]):format(math.floor((3 + self:getTalentLevel(t)) / 1.5))
	end,
}
