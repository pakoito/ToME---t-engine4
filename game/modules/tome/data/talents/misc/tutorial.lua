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

-- race & classes
newTalentType{ type="tutorial", name = "tutorial", hide = true, description = "Tutorial-specific talents." }

newTalent{
	name = "Shove", short_name = "TUTORIAL_PHYS_KB",
	type = {"tutorial", 1},
	points = 5,
	random_ego = "attack",
	cooldown = 0,
	requires_target = true,
	tactical = { ATTACK = 2},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		if self:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist()) then
			target:knockback(self.x, self.y, 1)
		else
			game.logSeen(target, "%s resists the shove!", target.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		return ([[Give the target a good old-fashioned shove, knocking it back a square.]])
	end,
}

newTalent{
	name = "Mana Gale", short_name = "TUTORIAL_SPELL_KB",
	type = {"tutorial", 1},
	points = 5,
	range = 3,
	random_ego = "attack",
	cooldown = 0,
	requires_target = true,
	tactical = { ATTACK = 2},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if self:checkHit(self:combatSpellpower(), target:combatPhysicalResist()) then
			target:knockback(self.x, self.y, self:getTalentLevel(t))
			game.logSeen(target, "%s is knocked back by the gale!", target.name:capitalize())
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatSpellpower())
		else
			game.logSeen(target, "%s remains firmly planted in the face of the gale!", target.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		local dist = self:getTalentLevel(t)
		return ([[Conjure up a powerful magical wind, pushing the target back a distance of %d.]]):format(dist)
	end,
}

newTalent{
	name = "Telekinetic Punt", short_name = "TUTORIAL_MIND_KB",
	type = {"tutorial", 1},
	points = 5,
	range = 3,
	random_ego = "attack",
	cooldown = 0,
	requires_target = true,
	tactical = { ATTACK = 2},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if self:checkHit(self:combatMindpower(), target:combatPhysicalResist()) then
			target:knockback(self.x, self.y, 1)
			game.logSeen(target, "%s is knocked back by the telekinetic blow!", target.name:capitalize())
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatMindpower())
		else
			game.logSeen(target, "%s holds its ground!", target.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		return ([[Knock the target backwards with a powerful telekinetic blow.]])
	end,
}

newTalent{
	name = "Blink", short_name = "TUTORIAL_SPELL_BLINK",
	type = {"tutorial", 1},
	points = 5,
	range = 3,
	random_ego = "attack",
	cooldown = 0,
	requires_target = true,
	tactical = { ATTACK = 2},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if self:checkHit(self:combatSpellpower(), target:combatSpellResist()) then
			target:knockback(self.x, self.y, 1)
			game.logSeen(target, "%s is teleported a short distance!", target.name:capitalize())
			target:crossTierEffect(target.EFF_SPELLSHOCKED, self:combatSpellpower())
		else
			game.logSeen(target, "%s resists the teleportation!", target.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		return ([[Attempts to magically teleport a target slightly farther from you.]])
	end,
}

newTalent{
	name = "Fear", short_name = "TUTORIAL_MIND_FEAR",
	type = {"tutorial", 1},
	points = 5,
	range = 3,
	random_ego = "attack",
	cooldown = 0,
	requires_target = true,
	tactical = { ATTACK = 2},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if self:checkHit(self:combatMindpower(), target:combatMentalResist()) then
			target:knockback(self.x, self.y, 1)
			game.logSeen(target, "%s retreats in terror!", target.name:capitalize())
			target:crossTierEffect(target.EFF_BRAINLOCKED, self:combatMindpower())
		else
			game.logSeen(target, "%s shakes off the fear!", target.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		return ([[Attempts to briefly terrify a target into retreating.]])
	end,
}

newTalent{
	name = "Bleed", short_name = "TUTORIAL_SPELL_BLEED",
	type = {"tutorial", 1},
	points = 5,
	range = 5,
	random_ego = "attack",
	cooldown = 0,
	requires_target = true,
	tactical = { ATTACK = 2},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if target then
			target:setEffect(self.EFF_CUT, 10, {power=1, apply_power=self:combatSpellpower()})
		end
		return true
	end,
	info = function(self, t)
		return ([[Inflicts a 10-turn bleed effect.]])
	end,
}

newTalent{
	name = "Confusion", short_name = "TUTORIAL_MIND_CONFUSION",
	type = {"tutorial", 1},
	points = 5,
	range = 3,
	random_ego = "attack",
	cooldown = 6,
	requires_target = true,
	tactical = { ATTACK = 2},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if target then
			target:setEffect(self.EFF_CONFUSED, 5, {power=100, apply_power=self:combatMindpower()})
		end
		return true
	end,
	info = function(self, t)
		return ([[Use your mental powers to confuse the target for five turns.]])
	end,
}
