-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	name = "Transcendent Pyrokinesis",
	type = {"psionic/thermal-mastery", 1},
	require = psi_wil_high1,
	points = 5,
	psi = 20,
	cooldown = 30,
	tactical = { BUFF = 3 },
	getPower = function(self, t) return self:combatTalentMindDamage(t, 10, 30) end,
	getPenetration = function(self, t) return self:combatLimit(self:combatTalentMindDamage(t, 10, 20), 100, 4.2, 4.2, 13.4, 13.4) end, -- Limit < 100%
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 30, 5, 10)) end, --Limit < 30
	action = function(self, t)
		self:setEffect(self.EFF_TRANSCENDENT_PYROKINESIS, t.getDuration(self, t), {power=t.getPower(self, t), penetration=t.getPenetration(self, t)})
		self:removeEffect(self.EFF_TRANSCENDENT_TELEKINESIS)
		self:removeEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS)
		self:alterTalentCoolingdown(self.T_THERMAL_SHIELD, -1000)
		self:alterTalentCoolingdown(self.T_THERMAL_STRIKE, -1000)
		self:alterTalentCoolingdown(self.T_THERMAL_AURA, -1000)
		self:alterTalentCoolingdown(self.T_THERMAL_LEECH, -1000)
		self:alterTalentCoolingdown(self.T_PYROKINESIS, -1000)
		return true
	end,
	info = function(self, t)
		return ([[For %d turns your pyrokinesis transcends your normal limits, increasing your Fire and Cold damage by %d%% and your Fire and Cold resistance penetration by %d%%.
		In addition:
		The cooldowns of Thermal Shield, Thermal Leech, Thermal Aura and Pyrokinesis are reset.
		Thermal Aura will either increase in radius to 2, or apply its damage bonus to all of your weapons, whichever is applicable.
		Your Thermal Shield will have 100%% absorption efficiency and will absorb twice the normal amount of damage.
		Pyrokinesis will inflict Flameshock.
		Thermal Leech will reduce enemy damage by %d%%.
		Thermal Strike will have its secondary cold/freeze explode in radius 1.
		The damage bonus and resistance penetration scale with your Mindpower.
		Only one Transcendent talent may be in effect at a time.]]):format(t.getDuration(self, t), t.getPower(self, t), t.getPenetration(self, t), t.getPower(self, t))
	end,
}

newTalent{
	name = "Brainfreeze",
	type = {"psionic/thermal-mastery", 2},
	require = psi_wil_high2, 
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	psi = 20,
	tactical = { ATTACK = { COLD = 3} },
	range = function(self,t) return self:combatTalentScale(t, 4, 6) end,
	getDamage = function (self, t)
		return self:combatTalentMindDamage(t, 12, 340)
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=0, selffire=false, talent=t} end,
	action = function(self, t)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		
		self:project(tg, x, y, DamageType.COLD, self:mindCrit(rng.avg(0.8*dam, dam)), {type="mindsear"})
		target:setEffect(target.EFF_BRAINLOCKED, 4, {apply_power=self:combatMindpower()})
		
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[Quickly drain the heat from your target's brain, dealing %0.1f Cold damage.
		Affected creatures will also be brainlocked for 4 turns, putting a random talent on cooldown, and freezing cooldowns.
		The damage and chance to brainlock increase with your Mindpower.]]):
		format(damDesc(self, DamageType.COLD, dam))
	end,
}

newTalent{
	name = "Heat Shift",
	type = {"psionic/thermal-mastery", 3},
	require = psi_wil_high3,
	points = 5,
	random_ego = "attack",
	cooldown = 15,
	psi = 35,
	tactical = { DISABLE = 4 },
	range = 6,
	radius = function(self,t) return self:combatTalentScale(t, 2, 4) end,
	getDuration = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 4, 8))
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t} end,
	action = function(self, t)
		local dur = t.getDuration(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, self.x, self.y, function(tx, ty)
			local act = game.level.map(tx, ty, engine.Map.ACTOR)
			if act then
				if target:canBe("pin") and target:canBe("stun") and not target:attr("fly") and not target:attr("levitation") then
					target:setEffect(target.EFF_FROZEN_FEET, dur, {apply_power=self:combatMindpower()})
				end
				if target:canBe("disarm") then
					target:setEffect(target.EFF_DISARMED, dur, {apply_power=self:combatMindpower()})
				end
			end
		end)
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self, t)
		local rad = self:getTalentRadius(t)
		return ([[Transfer heat from a group (radius %d) of enemies bodies to their weapons, freezing them to the floor while forcing them to drop their too weapons.
		Attempts to inflict Frozen Feet and Disarmed to target enemies for %d turns.
		The chance to apply the effects and the duration increase with your Mindpower.]]):
		format(rad, dur)
	end,
}

newTalent{
	name = "Thermal Balance",
	type = {"psionic/thermal-mastery", 4},
	require = psi_wil_high4,
	points = 5,
	psi = 0,
	cooldown = 10,
	range = function(self,t) return self:combatTalentScale(t, 4, 6) end,
	radius = function(self,t) return self:combatTalentScale(t, 2, 4) end,
	tactical = { ATTACKAREA = { FIRE = 2, COLD = 2 } },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 30, 300) end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		local dam=self:mindCrit(t.getDamage(self, t))
		local dam1 = dam * (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi()
		local dam2 = dam * self:getPsi() / self:getMaxPsi()
		
		self:project(tg, x, y, DamageType.COLD, dam1)
		self:project(tg, x, y, DamageType.FIRE, dam2)

		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=1.1, a=255, limit_life=16, grow=true, speed=0, img="fireice_nova", radius=tg.radius})
		
		self:incPsi(self:getMaxPsi()/2 - self:getPsi())
		
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		local dam1 = dam * (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi()
		local dam2 = dam * self:getPsi() / self:getMaxPsi()
		return ([[You seek balance between fire and cold based on your current Psi level.
		You blast your foes with %0.1f Fire damage based on your current Psi, %0.1f Cold damage based on your max Psi minus your current Psi, in a radius %d ball.
		This sets your current Psi to half of your maximum Psi.
		The damage scales with your Mindpower.]]):
		format(damDesc(self, DamageType.FIRE, dam2), damDesc(self, DamageType.COLD, dam1), self:getTalentRadius(t))
	end,
}

