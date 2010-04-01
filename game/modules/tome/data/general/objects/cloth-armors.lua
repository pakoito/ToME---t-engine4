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
	define_as = "BASE_CLOTH_ARMOR",
	slot = "BODY",
	type = "armor", subtype="cloth",
	add_name = " (#ARMOR#)",
	display = "[", color=colors.SLATE,
	encumber = 2,
	rarity = 5,
	desc = [[A cloth vestment. It offers no intrinsinc protection but can be enchanted.]],
	egos = "/data/general/objects/egos/robe.lua", egos_chance = resolvers.mbonus(30, 15),
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	name = "robe",
	level_range = {1, 50},
	cost = 0.5,
}
