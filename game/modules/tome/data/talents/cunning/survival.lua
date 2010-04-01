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
	name = "Trap Detection",
	type = {"cunning/survival", 1},
	require = cuns_req1,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[Your attention to details allows you to detect traps around you (%d detection 'power').]]):
		format(self:getTalentLevel(t) * self:getCun(25))
	end,
}

newTalent{
	name = "Evasion",
	type = {"cunning/survival", 2},
	points = 5,
	require = cuns_req2,
	stamina = 35,
	cooldown = 30,
	action = function(self, t)
		local dur = 5 + self:getWil(10)
		local chance = 5 * self:getTalentLevel(t) + self:getCun(25) + self:getDex(25)
		self:setEffect(self.EFF_EVASION, dur, {chance=chance})
		return true
	end,
	info = function(self, t)
		return ([[Your quick wit allows you to see attacks before they come, granting you %d%% chances to completly evade them for %d turns.
		Duration increases with Willpower and chances to evade with Cunning and Dexterity.]]):format(5 * self:getTalentLevel(t) + self:getCun(25) + self:getDex(25), 5 + self:getWil(10))
	end,
}

newTalent{
	name = "Trap Disarm",
	type = {"cunning/survival", 3},
	require = cuns_req3,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[You have learnt to disarm traps. (%d disarm power).]]):
		format(self:getTalentLevel(t) * self:getCun(25))
	end,
}

newTalent{
	name = "Long Strides",
	type = {"cunning/survival", 4},
	require = cuns_req4,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[Reduces the movement penality when moving over dangerous terrain.]]):
		format()
	end,
}
