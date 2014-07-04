-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	name = "Warshout", short_name = "WARSHOUT_BERSERKER", image = "talents/warshout.png",
	type = {"technique/strength-of-the-berserker",1},
	require = techs_req1,
	points = 5,
	message = function(self) if self.subtype == "rodent" then return "@Source@ uses Warsqueak." else return "@Source@ uses Warshout." end end ,
	stamina = 30,
	cooldown = 18,
	tactical = { ATTACKAREA = { confusion = 1 }, DISABLE = { confusion = 3 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then return nil end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.CONFUSION, {
			dur=t.getDuration(self, t),
			dam=50+self:getTalentLevelRaw(t)*10,
			power_check=function() return self:combatPhysicalpower() end,
			resist_check=self.combatPhysicalResist,
		})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "directional_shout", {life=8, size=3, tx=x-self.x, ty=y-self.y, distorion_factor=0.1, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0.4, gM=0.6, bm=0.1, bM=0.2, am=1, aM=1})
		if core.shader.allow("distort") then game.level.map:particleEmitter(self.x, self.y, tg.radius, "gravity_breath", {life=8, radius=tg.radius, tx=x-self.x, ty=y-self.y, allow=true}) end
		return true
	end,
	info = function(self, t)
		return ([[Shout your warcry in a frontal cone of radius %d. Any targets caught inside will be confused for %d turns.]]):
		format(self:getTalentRadius(t), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Berserker Rage", image = "talents/berserker.png",
	type = {"technique/strength-of-the-berserker", 2},
	require = techs_req2,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	no_energy = true,
	sustain_stamina = 20,
	no_npc_use = true, -- sad but the AI wouldnt use this well at all
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	getDam = function(self, t) return self:combatScale(self:getStr(7, true) * self:getTalentLevel(t), 5, 0, 40, 35)end,
	getAtk = function(self, t) return self:combatScale(self:getDex(7, true) * self:getTalentLevel(t), 5, 0, 40, 35) end ,
	getImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.17, 0.5) end,
	hasFoes = function(self)
		for i = 1, #self.fov.actors_dist do
			local act = self.fov.actors_dist[i]
			if act and self:reactionToward(act) < 0 and self:canSee(act) then return true end
		end
		return false
	end,
	callbackOnActBase = function(self, t)
		if t.hasFoes(self) then
			local v = (self.max_life * 0.02)
			if v >= self.life then v = 0 end

			if self:knowTalent(self.T_VITALITY) and self.life > self.max_life /2 and self.life - v <= self.max_life/2 then
				local tt = self:getTalentFromId(self.T_VITALITY)
				tt.do_vitality_recovery(self, tt)
			end

			self.life = self.life - v
		end
	end,
	callbackOnAct = function(self, t)
		local p = self.sustain_talents[t.id]
		if t.hasFoes(self) then
			t.enable(self, t, p)
		else
			t.disable(self, t, p)
		end
	end,
	enable = function(self, t, p)
		if not self:hasEffect(self.EFF_UNSTOPPABLE) then self:setEffect(self.EFF_BERSERKER_RAGE, 1, {power=(1 - (self.life / self.max_life)) * 100 * 0.5})
		else self:removeEffect(self.EFF_BERSERKER_RAGE, true, true)
		end
		if p.enabled then return end
		p.enabled = true
		p.stun = self:addTemporaryValue("stun_immune", t.getImmune(self, t))
		p.pin = self:addTemporaryValue("pin_immune", t.getImmune(self, t))
		p.dam = self:addTemporaryValue("combat_dam", t.getDam(self, t))
		p.atk = self:addTemporaryValue("combat_atk", t.getAtk(self, t))
		self:logCombat(self, "#Source#'s rage awakens!")
	end,
	disable = function(self, t, p)
		if p.enabled then
			self:logCombat(self, "#Source#'s rage subsides!")
			self:removeEffect(self.EFF_BERSERKER_RAGE, true, true)
			self:removeTemporaryValue("stun_immune", p.stun)
			self:removeTemporaryValue("pin_immune", p.pin)
			self:removeTemporaryValue("combat_atk", p.atk)
			self:removeTemporaryValue("combat_dam", p.dam)
		end
		p.enabled = false
	end,
	activate = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then return nil end

		local p = {}
		if t.hasFoes(self) then t.enable(self, t, p) end
		return p
	end,
	deactivate = function(self, t, p)
		t.disable(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[You enter an aggressive battle rage, increasing Accuracy by %d and Physical Power by %d and making you nearly unstoppable, granting %d%% stun and pinning resistance.
		Sustaining this rage takes its toll on your body, decreasing your life by 2%% each turn, but for every 1%% of life missing you gain 0.5%% critical hit chance.
		Even when sustained, this talent is only active when foes are in sight.
		The Accuracy bonus increases with your Dexterity, and the Physical Power bonus with your Strength.]]):
		format( t.getAtk(self, t), t.getDam(self, t), t.getImmune(self, t)*100)
	end,
}

newTalent{
	name = "Shattering Blow", image = "talents/sunder_armour.png",
	type = {"technique/strength-of-the-berserker", 3},
	require = techs_req3,
	points = 5,
	cooldown = function(self, t) return self:combatTalentLimit(t, 5, 15, 8) end,
	stamina = 12,
	requires_target = true,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	getShatter = function(self, t) return self:combatTalentLimit(t, 100, 10, 85) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	getArmorReduc = function(self, t) return self:combatTalentScale(t, 5, 25, 0.75) end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then return nil end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1, 1.5))

		-- Try to Sunder !
		if hit then
			target:setEffect(target.EFF_SUNDER_ARMOUR, t.getDuration(self, t), {power=t.getArmorReduc(self,t), apply_power=self:combatPhysicalpower()})

			if rng.percent(t.getShatter(self, t)) then
				local effs = {}

				-- Go through all shield effects
				for eff_id, p in pairs(target.tmp) do
					local e = target.tempeffect_def[eff_id]
					if e.status == "beneficial" and e.subtype and e.subtype.shield then
						effs[#effs+1] = {"effect", eff_id}
					end
				end

				for i = 1, 1 do
					if #effs == 0 then break end
					local eff = rng.tableRemove(effs)

					if eff[1] == "effect" then
						game.logSeen(self, "#CRIMSON#%s shatters %s shield!", self.name:capitalize(), target.name)
						target:removeEffect(eff[2])
					end
				end
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon, doing %d%% damage. If the attack hits, the target's armour and saves are reduced by %d for %d turns.
		Also if the target is protected by a temporary damage shield there is %d%% chance to shatter it.
		Armor reduction chance increases with your Physical Power.]])
		:format(100 * self:combatTalentWeaponDamage(t, 0.8, 1.4), t.getArmorReduc(self, t), t.getDuration(self, t), t.getShatter(self, t))
	end,
}

newTalent{
	name = "Relentless Fury",
	type = {"technique/strength-of-the-berserker", 4},
	require = techs_req4,
	points = 5,
	cooldown = 25,
	stamina = 0,
	range = 10,
	requires_target = true,
	tactical = { CLOSEIN = 2, STAMINA = 2, BUFF = 2 },
	getDur = function(self, t) return math.floor(self:combatTalentLimit(t, 19, 4, 8)) end,
	getStamina = function(self, t) return self:combatStatScale("con", 4, 25) end,
	getSpeed = function(self, t) return self:combatTalentLimit(t, 70, 10, 30) end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() or self:getStamina() > self:getMaxStamina() * 0.3 then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	action = function(self, t)
		self:setEffect(self.EFF_RELENTLESS_FURY, t.getDur(self, t), {stamina=t.getStamina(self, t), speed=t.getSpeed(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Search your inner strength for a surge of power.
		For %d turns you gain %d stamina per turn and %d%% movement and attack speed.
		Only usable at 30%% or lower stamina.
		Stamina regeneration is based on your Constitution stat.]]):
		format(t.getDur(self, t), t.getStamina(self, t), t.getSpeed(self, t))
	end,
}
