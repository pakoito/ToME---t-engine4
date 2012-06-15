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
	define_as = "BASE_HEAVY_BOOTS",
	slot = "FEET",
	type = "armor", subtype="feet", image = resolvers.image_material("hboots", "metal"),
	moddable_tile = resolvers.moddable_tile("heavy_boots"),
	add_name = " (#ARMOR#)",
	display = "]", color=colors.SLATE,
	require = { talent = { Talents.T_ARMOUR_TRAINING }, },
	encumber = 3,
	rarity = 7,
	metallic = true,
	desc = [[Heavy boots, with metal strips at the toes, heels and other vulnerable parts, to better protect the wearer's feet from harm.]],
	randart_able = "/data/general/objects/random-artifacts/generic.lua",
	egos = "/data/general/objects/egos/boots.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	name = "pair of iron boots", short_name = "iron",
	level_range = {1, 20},
	cost = 5,
	material_level = 1,
	wielder = {
		combat_armor = 3,
		fatigue = 2,
	},
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	name = "pair of dwarven-steel boots", short_name = "d.steel",
	level_range = {20, 40},
	cost = 7,
	material_level = 3,
	wielder = {
		combat_armor = 4,
		fatigue = 3,
	},
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	name = "pair of voratun boots", short_name = "voratun",
	level_range = {40, 50},
	cost = 10,
	material_level = 5,
	wielder = {
		combat_armor = 5,
		fatigue = 4,
	},
}
