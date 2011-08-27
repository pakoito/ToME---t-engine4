-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

local Map = require "engine.Map"

newTalent{
	name = "Hack'n'Back",
	type = {"technique/mobility", 1},
	points = 5,
	cooldown = 14,
	stamina = 30,
	tactical = { ESCAPE = 1, ATTACK = 0.5 },
	require = cuns_req1,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.4, 1) end,
	getDist = function(self, t) return 1 + math.ceil(self:getTalentLevel(t) / 2) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hitted then
			self:knockback(target.x, target.y, t.getDist(self, t))
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local dist = t.getDist(self, t)
		return ([[You hit your target doing %d%% damage, distracting it while you jump back %d squares away.]]):
		format(100 * damage, dist)
	end,
}

newTalent{
	name = "Mobile Defence",
	type = {"technique/mobility", 2},
	mode = "passive",
	points = 5,
	require = cuns_req2,
	getDef = function(self, t) return self:getTalentLevel(t) * 0.08 end,
	getHardiness = function(self, t) return self:getTalentLevel(t) * 0.06 end,
	info = function(self, t)
		return ([[Whilst wearing leather or lighter armour you gain %d%% defence and %d%% armour hardiness.]]):
		format(t.getDef(self, t) * 100, t.getHardiness(self, t) * 100)
	end,
}

newTalent{
	name = "Light of Foot",
	type = {"technique/mobility", 3},
	mode = "passive",
	points = 5,
	require = cuns_req3,
	on_learn = function(self, t)
		self.fatigue = (self.fatigue or 0) - 1.5
	end,
	on_unlearn = function(self, t)
		self.fatigue = (self.fatigue or 0) + 1.5
	end,
	info = function(self, t)
		return ([[You are light on foot, handling your armour better. Each step you take regenerates %0.2f stamina and your fatigue is permanently reduced by %d%%.]]):
		format(self:getTalentLevelRaw(t) * 0.2, self:getTalentLevelRaw(t) * 1.5)
	end,
}

newTalent{
	name = "Strider",
	type = {"technique/mobility", 4},
	points = 5,
	random_ego = "attack",
	cooldown = 25,
	stamina = 30,
	require = cuns_req4,
	requires_target = true,
	tactical = { DISABLE = 2, ATTACK = 2 },
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.9, 1.4) end,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	getAttackPenalty = function(self, t) return 10 + self:getTalentLevel(t) * 3 end,
	getDamagePenalty = function(self, t) return 10 + self:getTalentLevel(t) * 4 end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hitted then
			if target:checkHit(self:combatAttackDex(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) then
				local tw = target:getInven("MAINHAND")
				if tw then
					tw = tw[1] and tw[1].combat
				end
				tw = tw or target.combat
				local atk = target:combatAttack(tw) * (t.getAttackPenalty(self, t)) / 100
				local dam = target:combatDamage(tw) * (t.getDamagePenalty(self, t)) / 100
				target:setEffect(target.EFF_CRIPPLE, t.getDuration(self, t), {atk=atk, dam=dam})
			else
				game.logSeen(target, "%s is not crippled!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local attackpen = t.getAttackPenalty(self, t)
		local damagepen = t.getDamagePenalty(self, t)
		return ([[You hit your target doing %d%% damage. If your attack hits, the target is crippled for %d turns, losing %d%% accuracy and %d%% damage.
		Hit chance improves with talent level and your Dexterity stat.]]):
		format(100 * damage, duration, attackpen, damagepen)
	end,
}
