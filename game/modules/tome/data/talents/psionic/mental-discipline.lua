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




newTalent{
	name = "Aura Discipline",
	type = {"psionic/mental-discipline", 1},
	require = psi_wil_req1,
	points = 5,
	mode = "passive",
	info = function(self, t)
		local cooldown = self:getTalentLevelRaw(t)
		local mast = (self:getTalentLevel(t) or 0)
		return ([[Your expertise in the art of energy projection grows.
		Aura cooldowns are all reduced by %d turns. Aura damage drains energy more slowly (+%0.2f damage required to lose a point of energy).]]):format(cooldown, mast)
	end,
}

newTalent{
	name = "Shield Discipline",
	type = {"psionic/mental-discipline", 2},
	require = psi_wil_req2,
	points = 5,
	mode = "passive",
	info = function(self, t)
		local cooldown = 2*self:getTalentLevelRaw(t)
		local mast = 2*self:getTalentLevel(t)
		return ([[Your expertise in the art of energy absorption grows. Shield cooldowns are all reduced by %d turns, and the amount of damage absorption required to gain a point of energy is reduced by %0.2f.]]):
		format(cooldown, mast)
	end,

}



newTalent{
	name = "Iron Will",
	type = {"psionic/mental-discipline", 3},
	require = psi_wil_req3,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.combat_mentalresist = self.combat_mentalresist + 6
		self.stun_immune = (self.stun_immune or 0) + .1
	end,

	on_unlearn = function(self, t)
		self.combat_mentalresist = self.combat_mentalresist - 6
		self.stun_immune = (self.stun_immune or 0) - .1
	end,
	info = function(self, t)
		return ([[Improves mental saves by %d and stun immunity by %d%%]]):
		format(self:getTalentLevelRaw(t)*6, self:getTalentLevelRaw(t)*10)
	end,
}

newTalent{
	name = "Highly Trained Mind",
	type = {"psionic/mental-discipline", 4},
	mode = "passive",
	require = psi_wil_req4,
	points = 5,
	on_learn = function(self, t)
		self.inc_stats[self.STAT_WIL] = self.inc_stats[self.STAT_WIL] + 2
		self:onStatChange(self.STAT_WIL, 2)
		self.inc_stats[self.STAT_CUN] = self.inc_stats[self.STAT_CUN] + 2
		self:onStatChange(self.STAT_CUN, 2)
	end,
	on_unlearn = function(self, t)
		self.inc_stats[self.STAT_WIL] = self.inc_stats[self.STAT_WIL] - 2
		self:onStatChange(self.STAT_WIL, -2)
		self.inc_stats[self.STAT_CUN] = self.inc_stats[self.STAT_CUN] - 2
		self:onStatChange(self.STAT_CUN, -2)
	end,
	info = function(self, t)
		return ([[A life of the mind has had predictably good effects on your Willpower and Cunning.
		Increases Willpower and Cunning by %d.]]):format(2*self:getTalentLevelRaw(t))
	end,
}
