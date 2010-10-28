-- ToME - Tales of Maj'Eyal
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

local Map = require "engine.Map"

newTalent{
	name = "Dirty Fighting",
	type = {"cunning/dirty", 1},
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	stamina = 10,
	require = cuns_req1,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.2, 0.7), true)

		if hitted then
			if target:checkHit(self:combatAttackDex(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 3 + math.ceil(self:getTalentLevel(t)), {})
			else
				game.logSeen(target, "%s resists the stun!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[You hit your target doing %d%% damage, trying to stun it instead of damaging it. If your attack hits, the target is stunned for %d turns.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.2, 0.7), 3 + math.ceil(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Backstab",
	type = {"cunning/dirty", 2},
	mode = "passive",
	points = 5,
	require = cuns_req2,
	info = function(self, t)
		return ([[Your quick wit gives you a big advantage against stunned targets; all your hits will have a %d%% greater chance of being critical.]]):
		format(self:getTalentLevel(t) * 10)
	end,
}
newTalent{
	name = "Switch Place",
	type = {"cunning/dirty", 3},
	points = 5,
	random_ego = "defensive",
	cooldown = 10,
	stamina = 50,
	require = cuns_req3,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, 0, true)

		if hitted then
			local dur = 1 + self:getTalentLevel(t)
			self:setEffect(self.EFF_EVASION, dur, {chance=50})

			-- Displace
			local tx, ty, sx, sy = target.x, target.y, self.x, self.y
			target.x = nil target.y = nil
			self.x = nil self.y = nil
			target:move(sx, sy, true)
			self:move(tx, ty, true)
		end

		return true
	end,
	info = function(self, t)
		return ([[Using a series of tricks and maneuvers, you switch places with your target.
		Switching places will confuse your foes for a few turns, granting you evasion(50%%) for %d turns.]]):
		format(1 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Cripple",
	type = {"cunning/dirty", 4},
	points = 5,
	random_ego = "attack",
	cooldown = 25,
	stamina = 30,
	require = cuns_req4,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.9, 1.4), true)

		if hitted then
			if target:checkHit(self:combatAttackDex(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) then
				local tw = target:getInven("MAINHAND")
				if tw then
					tw = tw[1] and tw[1].combat
				end
				tw = tw or target.combat
				local atk = target:combatAttack(tw) * (10 + self:getTalentLevel(t) * 3) / 100
				local dam = target:combatDamage(tw) * (10 + self:getTalentLevel(t) * 4) / 100
				target:setEffect(target.EFF_CRIPPLE, 3 + math.ceil(self:getTalentLevel(t)), {atk=atk, dam=dam})
			else
				game.logSeen(target, "%s is not crippled!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[You hit your target doing %d%% damage. If your attack hits, the target is crippled for %d turns, losing %d%% attack and %d%% damage.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.9, 1.4), 3 + math.ceil(self:getTalentLevel(t)), 10 + self:getTalentLevel(t) * 3, 10 + self:getTalentLevel(t) * 4)
	end,
}
