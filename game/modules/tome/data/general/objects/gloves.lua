-- ToME - Tales of Maj'Eyal
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

local Talents = require "engine.interface.ActorTalents"

newEntity{
	define_as = "BASE_GLOVES",
	slot = "HANDS",
	type = "armor", subtype="hands",
	add_name = " (#ARMOR#)",
	display = "[", color=colors.UMBER,
	image = resolvers.image_material("gloves", "leather"),
	encumber = 1,
	rarity = 9,
	desc = [[Light gloves which do not seriously hinder finger movements, while still protecting the hands somewhat.]],
	egos = "/data/general/objects/egos/gloves.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_GLOVES",
	name = "rough leather gloves",
	level_range = {1, 20},
	cost = 5,
	material_level = 1,
	wielder = {
		combat_armor = 1,
	},
}

newEntity{ base = "BASE_GLOVES",
	name = "hardened leather gloves",
	level_range = {20, 40},
	cost = 7,
	material_level = 3,
	wielder = {
		combat_armor = 2,
	},
}

newEntity{ base = "BASE_GLOVES",
	name = "drakeskin leather gloves",
	level_range = {40, 50},
	cost = 10,
	material_level = 5,
	wielder = {
		combat_armor = 3,
	},
}
