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
	name = "Efficient Packing",
	type = {"cunning/packing", 1},
	require = cuns_req1,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self:checkEncumbrance()
	end,
	on_unlearn = function(self, t)
		self:checkEncumbrance()
	end,
	info = function(self, t)
		return ([[Arrange your small items (of one or less encumberance value) to gain space, reducing their encumberance by %d%%.]]):
		format(self:getTalentLevel(t) * 10)
	end,
}

newTalent{
	name = "Insulating Packing",
	type = {"cunning/packing", 2},
	require = cuns_req2,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self.heightened_senses = 4 + math.ceil(self:getTalentLevel(t))
	end,
	on_unlearn = function(self, t)
		if self:knowTalent(t) then
			self.heightened_senses = 4 + math.ceil(self:getTalentLevel(t))
		else
			self.heightened_senses = nil
		end
	end,
	info = function(self, t)
		return ([[Arrange your items in better way, protecting those that can easily be destroyed reducing their chance to be destroyed by %d%%.]]):
		format(self:getTalentLevel(t) * 14)
	end,
}

newTalent{
	name = "Burden Management",
	type = {"cunning/packing", 3},
	require = cuns_req3,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self:checkEncumbrance()
	end,
	on_unlearn = function(self, t)
		self:checkEncumbrance()
	end,
	info = function(self, t)
		return ([[Learn to manage heavy burden using cunning balance, increasing your maximun encumberance by %d.]]):
		format(20 + self:getTalentLevel(t) * 15)
	end,
}

newTalent{
	name = "Pack Rat",
	type = {"cunning/packing", 4},
	points = 5,
	require = cuns_req4,
	mode = "passive",
	info = function(self, t)
		return ([[Your pack is bigger than you remember, when you use a scroll/potion/ammo you have %d%% to find a new one in your pack.]]):
		format(10 + self:getTalentLevel(t) * 7)
	end,
}
