-- ToME - Tales of Middle-Earth
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
	name = "Absorb Soul",
	type = {"spell/necromancy",1},
	require = spells_req1,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		-- learn soul pool, gain capacity of 4, or increase with each talent
		if not self:knowTalent(self.T_SOUL_POOL) then
			self:learnTalent(self.T_SOUL_POOL)
			self:incSoul(-1000000)
		end
		self.max_soul = 4 + self:getTalentLevelRaw(t)
		return true
	end,
	on_unlearn = function(self, t, p)
		if self:knowTalent(self.T_SOUL_POOL) and self:getTalentLevelRaw(t) == 0 then
			self:unlearnTalent(self.T_SOUL_POOL)
		end
		self.max_soul = 4 + self:getTalentLevelRaw(t)
		return true
	end,
	info = function(self, t)
		return ([[Absorbing souls is the base of the necromantic arts. Whenever you slay a foe that grants experience you absorb its life-force, or soul for sentient beings.
		This energy is is used to fuel all other necromantic spells.
		]]):format()
	end,
}
