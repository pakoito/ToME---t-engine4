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

local Map = require "engine.Map"

newTalent{
	name = "Dirty Fighting",
	type = {"cunning/dirty", 1},
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	stamina = 10,
	tactical = { DISABLE = {stun = 2}, ATTACK = {weapon = 0.5} },
	require = cuns_req1,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 0.7) end,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hitted then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatAttack()})
			else
				game.logSeen(target, "%s resists the stun!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[You hit your target doing %d%% damage, trying to stun it instead of damaging it. If your attack hits, the target is stunned for %d turns.
		Stun chance increase with talent level and your Dexterity stat.]]):
		format(100 * damage, duration)
	end,
}

newTalent{
	name = "Backstab",
	type = {"cunning/dirty", 2},
	mode = "passive",
	points = 5,
	require = cuns_req2,
	getCriticalChance = function(self, t) return self:getTalentLevel(t) * 10 end,
	info = function(self, t)
		local chance = t.getCriticalChance(self, t)
		return ([[Your quick wit gives you a big advantage against stunned targets; all your hits will have a %d%% greater chance of being critical.]]):
		format(chance)
	end,
}
newTalent{
	name = "Switch Place",
	type = {"cunning/dirty", 3},
	points = 5,
	random_ego = "defensive",
	cooldown = 10,
	stamina = 15,
	require = cuns_req3,
	requires_target = true,
	tactical = { DISABLE = 2 },
	getDuration = function(self, t) return 1 + self:getTalentLevel(t) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local tx, ty, sx, sy = target.x, target.y, self.x, self.y
		local hitted = self:attackTarget(target, nil, 0, true)

		if hitted and not self.dead then
			self:setEffect(self.EFF_EVASION, t.getDuration(self, t), {chance=50})

			-- Displace
			if not target.dead then
				self.x = nil self.y = nil
				self:move(tx, ty, true)
				target.x = nil target.y = nil
				target:move(sx, sy, true)
			end
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Using a series of tricks and maneuvers, you switch places with your target.
		Switching places will confuse your foes, granting you evasion(50%%) for %d turns.
		While switching places your weapon(s) will connect with the target, not damaging it but on hit effects can trigger.]]):
		format(duration)
	end,
}

newTalent{
	name = "Cripple",
	type = {"cunning/dirty", 4},
	points = 5,
	random_ego = "attack",
	cooldown = 25,
	stamina = 20,
	require = cuns_req4,
	requires_target = true,
	tactical = { DISABLE = 2, ATTACK = {weapon = 2} },
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.9, 1.4) end,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	getAttackPenalty = function(self, t) return 5 + self:combatTalentStatDamage(t, "cun", 10, 60) end,
	getDamagePenalty = function(self, t) return 5 + self:combatTalentStatDamage(t, "cun", 10, 50) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hitted then
			local tw = target:getInven("MAINHAND")
			if tw then
				tw = tw[1] and tw[1].combat
			end
			tw = tw or target.combat
			local atk = target:combatAttack(tw) * (t.getAttackPenalty(self, t)) / 100
			local dam = target:combatDamage(tw) * (t.getDamagePenalty(self, t)) / 100
			target:setEffect(target.EFF_CRIPPLE, t.getDuration(self, t), {atk=atk, dam=dam, apply_power=self:combatAttack()})
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

