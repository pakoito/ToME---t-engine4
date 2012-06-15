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
	define_as = "BASE_CLOTH_ARMOR",
	slot = "BODY",
	type = "armor", subtype="cloth",
	add_name = " (#ARMOR#)",
	display = "[", color=colors.SLATE, image = resolvers.image_material("robe", "cloth"),
	moddable_tile = resolvers.moddable_tile("robe"),
	encumber = 2,
	rarity = 5,
	desc = [[A cloth vestment. It offers no intrinsic protection but can be enchanted.]],
	randart_able = "/data/general/objects/random-artifacts/generic.lua",
	egos = "/data/general/objects/egos/robe.lua", egos_chance = { prefix=resolvers.mbonus(30, 15), suffix=resolvers.mbonus(30, 15) },
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	name = "linen robe", short_name = "linen",
	level_range = {1, 10},
	cost = 0.5,
	material_level = 1,
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	name = "woollen robe", short_name = "wollen",
	level_range = {10, 20},
	cost = 1.5,
	material_level = 2,
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	name = "cashmere robe", short_name = "cashmere",
	level_range = {20, 30},
	cost = 2.5,
	material_level = 3,
	wielder = {
		combat_def = 2,
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	name = "silk robe", short_name = "silk",
	level_range = {30, 40},
	cost = 3.5,
	material_level = 4,
	wielder = {
		combat_def = 3,
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	name = "elven-silk robe", short_name = "e.silk",
	level_range = {40, 50},
	cost = 5.5,
	material_level = 5,
	wielder = {
		combat_def = 5,
	},
}
