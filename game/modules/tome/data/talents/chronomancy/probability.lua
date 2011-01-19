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
	name = "Probability Weaving",
	type = {"chronomancy/probability", 1},
	require = temporal_req1,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[Bends the laws of probability, increasing your defense by %d and reducing the chance you'll be critically hit by %d%%]]):format(self:getTalentLevel(t) * 2,  self:getTalentLevel(t))
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
	paradox = 5,
	cooldown = 20,
	tactical = { BUFF = 2 },
	no_energy = true,
	getDuration = function(self, t) return math.ceil((self:getTalentLevel(t) + 4) * getParadoxModifier(self, pm)) end,
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 20, 60)*getParadoxModifier(self, pm) end,
	action = function(self, t)
		self:setEffect(self.EFF_PERFECT_AIM, t.getDuration(self, t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		return ([[You focus your aim for the next %d turns, increasing your critical damage multiplier by %d%%..
		The damage multiplier will improve with the Magic stat.]]):format(duration, power)
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
