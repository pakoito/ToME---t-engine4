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
	define_as = "BASE_LIGHT_ARMOR",
	slot = "BODY",
	type = "armor", subtype="light",
	add_name = " (#ARMOR#)",
	display = "[", color=colors.SLATE, image = resolvers.image_material("leather", "leather"),
	moddable_tile = resolvers.moddable_tile("light"),
	encumber = 9,
	rarity = 5,
	desc = [[A suit of armour made of leather.]],
	randart_able = "/data/general/objects/random-artifacts/generic.lua",
	egos = "/data/general/objects/egos/light-armor.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	name = "rough leather armour", short_name = "rough",
	level_range = {1, 10},
	require = { stat = { str=10 }, },
	cost = 10,
	material_level = 1,
	wielder = {
		combat_def = 1,
		combat_armor = 2,
		fatigue = 6,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	name = "cured leather armour", short_name = "cured",
	level_range = {10, 20},
	require = { stat = { str=14 }, },
	cost = 12,
	material_level = 2,
	wielder = {
		combat_def = 2,
		combat_armor = 4,
		fatigue = 7,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	name = "hardened leather armour", short_name = "hardened",
	level_range = {20, 30},
	require = { stat = { str=16 }, },
	cost = 15,
	material_level = 3,
	wielder = {
		combat_def = 3,
		combat_armor = 6,
		fatigue = 8,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	name = "reinforced leather armour", short_name = "reinforced",
	level_range = {30, 40},
	cost = 20,
	require = { stat = { str=18 }, },
	material_level = 4,
	wielder = {
		combat_def = 4,
		combat_armor = 7,
		fatigue = 8,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	name = "drakeskin leather armour", short_name = "drakeskin",
	level_range = {40, 50},
	require = { stat = { str=20 }, },
	cost = 25,
	material_level = 5,
	wielder = {
		combat_def = 5,
		combat_armor = 8,
		fatigue = 8,
	},
}

