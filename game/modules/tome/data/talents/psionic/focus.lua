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

--Mindlash: ranged physical rad-0 ball
--Pyrokinesis: LOS burn attack
--Reach: gem-based range improvements
--Channeling: gem-based shield and improvement

newTalent{
	name = "Mindlash",
	type = {"psionic/focus", 1},
	require = psi_wil_high1,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t)
		local c = 5
		local gem_level = getGemLevel(self)
		return math.max(c - gem_level, 0)
	end,
	psi = 10,
	tactical = { ATTACK = 2 },
	range = function(self, t)
		local r = 5
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		r = math.floor(r*mult)
		return math.min(r, 10)
	end,
	getDamage = function (self, t)
		local gem_level = getGemLevel(self)
		return self:combatTalentIntervalDamage(t, "wil", 6, 265)*(1 + 0.3*gem_level)
	end,
	action = function(self, t)
		--local gem_level = getGemLevel(self)
		--local dam = (5 + self:getTalentLevel(t) * self:getWil(40))*(1 + 0.3*gem_level)
		local dam = t.getDamage(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=0, selffire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSICAL, self:spellCrit(rng.avg(0.8*dam, dam)), {type="flame"})
		return true
	end,
	info = function(self, t)
		--local gem_level = getGemLevel(self)
		--local dam = (5 + self:getTalentLevel(t) * self:getWil(40))*(1 + 0.3*gem_level)
		local dam = t.getDamage(self, t)
		return ([[Focus energies on a distant target to lash it with physical force, doing %d damage.
		Mindslayers do not do this sort of ranged attack naturally. The use of a telekinetically-wielded gem as a focus will improve the effects considerably.]]):
		format(dam)
	end,
}

newTalent{
	name = "Pyrokinesis",
	type = {"psionic/focus", 2},
	require = psi_wil_high2,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t)
		local c = 20
		local gem_level = getGemLevel(self)
		return c - gem_level
	end,
	psi = 20,
	tactical = { ATTACK = 2 },
	range = 0,
	radius = function(self, t)
		local r = 5
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		r = math.floor(r*mult)
		return math.min(r, 10)
	end,
	getDamage = function (self, t)
		local gem_level = getGemLevel(self)
		return self:combatTalentIntervalDamage(t, "wil", 21, 281)*(1 + 0.3*gem_level)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false}
	end,
	action = function(self, t)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.FIREBURN, {dur=10, initial=0, dam=dam}, {type="ball_fire", args={radius=1}})
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		--local gem_level = getGemLevel(self)
		--local dam = (20 + self:getTalentLevel(t) * self:getWil(40))*(1 + 0.3*gem_level)
		local dam = t.getDamage(self, t)
		return ([[Focus energies on all foes within %d squares, setting them ablaze. Does %d damage over ten turns.
		Mindslayers do not do this sort of ranged attack naturally. The use of a telekinetically-wielded gem as a focus will improve the effects considerably.]]):
		format(radius, dam)
	end,
}

newTalent{
	name = "Reach",
	type = {"psionic/focus", 3},
	require = psi_wil_high3,
	mode = "passive",
	points = 5,
	info = function(self, t)
		local inc = 2*self:getTalentLevel(t)
		return ([[You can extend your mental reach beyond your natural limits using a telekinetically-wielded gemstone as a focus. Increases the range of various abilities by %d%% to %d%%, depending on the quality of the gem used as a focus.]]):
		format(inc, 5*inc)
	end,
}

newTalent{
	name = "Focused Channeling",
	type = {"psionic/focus", 4},
	require = psi_wil_high4,
	mode = "passive",
	points = 5,
	info = function(self, t)
		local inc = 1 + 0.1*self:getTalentLevel(t)
		return ([[You can channel more energy with your auras and shields using a telekinetically-wielded gemstone as a focus. Increases the base strength of all auras and shields by %0.2f to %0.2f, depending on the quality of the gem used as a focus.]]):
		format(inc, 5*inc)
	end,
}
