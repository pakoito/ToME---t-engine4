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

newEntity{
	define_as = "BASE_MONEY",
	type = "money", subtype="money",
	display = "$", color=colors.YELLOW,
	encumber = 0,
	rarity = 5,
	identified = true,
	desc = [[All that glisters is not gold, all that is gold does not glitter.]],
	on_prepickup = function(self, who, id)
		who.money = who.money + self.money_value / 10
		-- Remove from the map
		game.level.map:removeObject(who.x, who.y, id)
		return true
	end,
}

newEntity{ base = "BASE_MONEY",
	name = "gold pieces",
	add_name = " (#MONEY#)",
	level_range = {1, 50},
	money_value = resolvers.rngavg(1, 20),
}

newEntity{ base = "BASE_MONEY",
	name = "huge pile of gold pieces",
	add_name = " (#MONEY#)",
	level_range = {30, 50},
	color=colors.GOLD,
	rarity = 15,
	money_value = resolvers.rngavg(30, 50),
}
