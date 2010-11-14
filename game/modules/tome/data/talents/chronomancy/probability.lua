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

newTalent{
	name = "Probability Shield",
	type = {"chronomancy/probability", 1},
	require = temporal_req1,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self.combat_def = self.combat_def + 2
	end,
	on_unlearn = function(self, t)
		self.combat_def = self.combat_def - 2
	end,
	info = function(self, t)
		return ([[Bends the laws of probability, increasing your defense by %d and reducing the chance you'll be critically hit by %d%%]]):format(self:getTalentLevelRaw(t) * 2,  self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Destiny Weaving",
	type = {"chronomancy/probability", 2},
	require = temporal_req2,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self:incStat(self.STAT_LCK, 2)
	end,
	on_unlearn = function(self, t)
		self:incStat(self.STAT_LCK, -2)
	end,
	info = function(self, t)
		return ([[You've learned to weave your own destiny.  Increases your luck by %d]]):format(self:getTalentLevelRaw(t) * 2)
	end,
}

newTalent{
	name = "Perfect Aim",
	type = {"chronomancy/probability",3},
	require = temporal_req3,
	points = 5,
	mode = "passive",
	info = function(self, t)
		return ([[Your critical strikes land with more precision then usual.  Increases the damage of all critical hits by %d%%.]]):
		format(self:getTalentLevel(t) * 10)
	end,
}

newTalent{
	name = "Avoid Fate",
	type = {"chronomancy/probability", 4},
	require = temporal_req4,
	points = 5,
	mode = "passive",
	info = function(self, t)
		return ([[As long as your life is at or above %d any single attack that would reduce you below 1 life instead reduces you to 1 life.]]):
		format(self.max_life * (.6 - (self:getTalentLevel(self.T_AVOID_FATE)/20)))
	end,
}