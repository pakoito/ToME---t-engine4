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

local Talents = require "engine.interface.ActorTalents"

newEntity{
	define_as = "BASE_HEAVY_ARMOR",
	slot = "BODY",
	type = "armor", subtype="heavy", image = resolvers.image_material("mail", "metal"),
	moddable_tile = resolvers.moddable_tile("heavy"),
	add_name = " (#ARMOR#)",
	display = "[", color=colors.SLATE,
	require = { talent = { {Talents.T_ARMOUR_TRAINING,2} }, },
	encumber = 14,
	rarity = 5,
	metallic = true,
	desc = [[A suit of armour made of mail.]],
	randart_able = "/data/general/objects/random-artifacts/generic.lua",
	egos = "/data/general/objects/egos/heavy-armor.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	name = "iron mail armour", short_name = "",
	level_range = {1, 10},
	require = { stat = { str=14 }, },
	cost = 20,
	material_level = 1,
	wielder = {
		combat_def = 2,
		combat_armor = 4,
		fatigue = 12,
	},
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	name = "steel mail armour", short_name = "steel",
	level_range = {10, 20},
	require = { stat = { str=20 }, },
	cost = 25,
	material_level = 2,
	wielder = {
		combat_def = 2,
		combat_armor = 6,
		fatigue = 14,
	},
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	name = "dwarven-steel mail armour", short_name = "d.steel",
	level_range = {20, 30},
	require = { stat = { str=28 }, },
	cost = 30,
	material_level = 3,
	wielder = {
		combat_def = 3,
		combat_armor = 8,
		fatigue = 16,
	},
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	name = "stralite mail armour", short_name = "stralite",
	level_range = {30, 40},
	cost = 40,
	material_level = 4,
	require = { stat = { str=38 }, },
	wielder = {
		combat_def = 4,
		combat_armor = 8,
		fatigue = 16,
	},
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	name = "voratun mail armour", short_name = "voratun",
	level_range = {40, 50},
	require = { stat = { str=48 }, },
	cost = 50,
	material_level = 5,
	wielder = {
		combat_def = 5,
		combat_armor = 10,
		fatigue = 16,
	},
}
