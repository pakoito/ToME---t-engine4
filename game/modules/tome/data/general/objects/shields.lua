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
	define_as = "BASE_SHIELD",
	slot = "OFFHAND",
	type = "armor", subtype="shield",
	add_name = " (#ARMOR#, #SHIELD#)",
	display = ")", color=colors.UMBER, image = resolvers.image_material("shield", "metal"),
	moddable_tile = resolvers.moddable_tile("shield"),
	rarity = 5,
	encumber = 7,
	metallic = true,
	desc = [[Handheld deflection devices]],
	require = { talent = { {Talents.T_ARMOUR_TRAINING,3} }, },
	randart_able = "/data/general/objects/random-artifacts/shields.lua",
	special_combat = { damrange = 1.2 },
	egos = "/data/general/objects/egos/shield.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

-- All shields have a "special_combat" field, this is used to compute damage made with them
-- when using special talents

newEntity{ base = "BASE_SHIELD",
	name = "iron shield", short_name = "iron",
	level_range = {1, 10},
	require = { stat = { str=11 }, },
	cost = 5,
	material_level = 1,
	special_combat = {
		dam = resolvers.rngavg(7,11),
		block = resolvers.rngavg(15, 25),
		physcrit = 2.5,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 2,
		combat_def = 4,
		combat_def_ranged = 4,
		fatigue = 6,
		learn_talent = { [Talents.T_BLOCK] = 1, },
	},
}

newEntity{ base = "BASE_SHIELD",
	name = "steel shield", short_name = "steel",
	level_range = {10, 20},
	require = { stat = { str=16 }, },
	cost = 10,
	material_level = 2,
	special_combat = {
		dam = resolvers.rngavg(10,20),
		block = resolvers.rngavg(35, 45),
		physcrit = 3,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 2,
		combat_def = 6,
		combat_def_ranged = 6,
		fatigue = 8,
		learn_talent = { [Talents.T_BLOCK] = 2, },
	},
}

newEntity{ base = "BASE_SHIELD",
	name = "dwarven-steel shield", short_name = "d.steel",
	level_range = {20, 30},
	require = { stat = { str=24 }, },
	cost = 15,
	material_level = 3,
	special_combat = {
		dam = resolvers.rngavg(25,35),
		block = resolvers.rngavg(70, 90),
		physcrit = 3.5,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 2,
		combat_def = 8,
		combat_def_ranged = 8,
		fatigue = 12,
		learn_talent = { [Talents.T_BLOCK] = 3, },
	},
}

newEntity{ base = "BASE_SHIELD",
	name = "stralite shield", short_name = "stralite",
	level_range = {30, 40},
	require = { stat = { str=35 }, },
	cost = 25,
	material_level = 4,
	special_combat = {
		dam = resolvers.rngavg(40,55),
		block = resolvers.rngavg(130, 150),
		physcrit = 4.5,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 2,
		combat_def = 10,
		combat_def_ranged = 10,
		fatigue = 14,
		learn_talent = { [Talents.T_BLOCK] = 4, },
	},
}

newEntity{ base = "BASE_SHIELD",
	name = "voratun shield", short_name = "voratun",
	level_range = {40, 50},
	require = { stat = { str=48 }, },
	cost = 35,
	material_level = 5,
	special_combat = {
		dam = resolvers.rngavg(60,75),
		block = resolvers.rngavg(180, 220),
		physcrit = 5,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 3,
		combat_def = 12,
		combat_def_ranged = 12,
		fatigue = 14,
		learn_talent = { [Talents.T_BLOCK] = 5, },
	},
}
