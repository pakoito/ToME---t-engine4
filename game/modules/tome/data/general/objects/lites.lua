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

newEntity{
	define_as = "BASE_LITE",
	slot = "LITE",
	type = "lite", subtype="lite", image = resolvers.image_material("lite", {"brass","","dwarven","","faenorian"}),
	display = "~",
	desc = [[Light up the dark places of the world!]],
	randart_able = "/data/general/objects/random-artifacts/generic.lua",
	egos = "/data/general/objects/egos/lite.lua", egos_chance = { prefix=resolvers.mbonus(15, 3), suffix=resolvers.mbonus(15, 3) },
}

newEntity{ base = "BASE_LITE",
	name = "brass lantern", color=colors.UMBER, short_name = "brass",
	desc = [[A brass container with a wick emerging from it, protected from draughts by a sheet of greased paper. It can be carried by a handle.]],
	level_range = {1, 20},
	rarity = 7,
	encumber = 2,
	cost = 0.5,
	material_level = 1,

	wielder = {
		lite = 2,
	},
}

newEntity{ base = "BASE_LITE",
	name = "alchemist's lamp", color=colors.LIGHT_UMBER, short_name = "alchemist",
	desc = [[A normal brass lantern, enhanced by alchemy to make it brighter.]],
	level_range = {20, 35},
	rarity = 10,
	encumber = 1,
	cost = 3,
	material_level = 3,

	wielder = {
		lite = 3,
	},
}

newEntity{ base = "BASE_LITE",
	name = "dwarven lantern", color=colors.GOLD, short_name = "dwarven",
	desc = [[Made by the Dwarves, this lantern provides light in the darkest recesses of the earth.]],
	level_range = {35, 50},
	rarity = 12,
	encumber = 1,
	cost = 4,
	material_level = 5,

	wielder = {
		lite = 4,
	},
}

