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
	getPower = function(self, t) return self:combatTalentMindDamage(t, 10, 20) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 10)) end,
	action = function(self, t)
		self:setEffect(self.EFF_TRANSCENDENT_PYROKINESIS, t.getDuration(self, t), {power=t.getPower(self, t)})
		self:removeEffect(self.EFF_TRANSCENDENT_TELEKINESIS)
		self:removeEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS)
		self.talents_cd[self.T_THERMAL_LEECH] = 0
		self.talents_cd[self.T_THERMAL_AURA] = 0
		self.talents_cd[self.T_THERMAL_SHIELD] = 0
		self.talents_cd[self.T_PYROKINESIS] = 0
		return true
	end,
	info = function(self, t)
		return ([[For %d turns your pyrokinesis transcends your normal limits, increasing your fire/cold damage and resistance penetration by %d%%.
		Thermal Shield, Thermal Leech, Thermal Aura and Pyrokinesis will have their cooldowns reset.
		Thermal Aura will increase to radius 2, or apply its damage bonus to all your weapons, whichever is applicable.
		Thermal Shield will have 100%% damage absorption efficiency.
		Pyrokinesis will inflict Flameshock.
		Thermal Leech will weaken enemy damage by %d%%.
		Damage bonus and penetration scale with your mindpower.
		Only one Transcendent talent may be in effect at a time.]]):format(t.getDuration(self, t), t.getPower(self, t), t.getPower(self, t))
	end,
}

newTalent{
	name = "Brainfreeze",
	type = {"psionic/thermal-mastery", 2},
	require = psi_wil_high2, 
	points = 5,
	random_ego = "attack",
	cooldown = 4,
	psi = 20,
	tactical = { ATTACK = { COLD = 3} },
	range = 5,
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
		return ([[Quickly drain the heat from your target's brain, dealing %0.2f cold damage.
		Affected creatures will also be brainlocked for 4 turns, puting a random talent on cooldown, and freezing cooldowns.
		The damage will scale with your Mindpower.]]):
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
	getDuration = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 2, 6))
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=2, selffire=false, talent=t} end,
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
		return ([[Move heat from a group of enemies feet into their weapons, freezing them to the spot and making them drop their too hot weapons.
		Attempts to inflict Frozen Feet and Disarmed to target enemies for %d turns.
		The duration will improve with your Mindpower.]]):
		format(dur)
	end,
}

newTalent{
	name = "Thermal Balance",
	type = {"psionic/thermal-mastery", 4},
	require = psi_wil_high4,
	points = 5,
	psi = 0,
	cooldown = 10,
	range = 4,
	radius = 3,
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
		
		self:incPsi(self:getMaxPsi()/2 - self:getPsi())
		
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		local dam1 = dam * (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi()
		local dam2 = dam * self:getPsi() / self:getMaxPsi()
		return ([[Placeholder description. :/
		%0.2f fire damage based on your current psi, %0.2f cold damage based on your max psi minus your current psi, in a radius 3 ball.
		Sets your current Psi to half your maximum Psi.
		Damage scales with your mindpower.]]):
		format(damDesc(self, DamageType.FIRE, dam2), damDesc(self, DamageType.COLD, dam1))
	end,
}

