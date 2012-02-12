-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	add_name = " (#SHIELD#)",
	display = ")", color=colors.UMBER, image = resolvers.image_material("shield", "metal"),
	moddable_tile = resolvers.moddable_tile("shield"),
	rarity = 5,
	encumber = 7,
	metallic = true,
	desc = [[Handheld deflection devices]],
	require = { talent = { {Talents.T_ARMOUR_TRAINING,3} }, },
	randart_able = { attack=20, physical=10, spell=10, def=50, misc=10 },
	special_combat = { damrange = 1 },
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
		dam = resolvers.cbonus(5),
		block = resolvers.cbonus(20),
		max_acc = 75,
		critical_power = 1.1,
		dammod = {str=0.2},
	},
	wielder = {
		fatigue = 6,
		learn_talent = {
			[Talents.T_BLOCK] = 1,
		},
	},
}

newEntity{ base = "BASE_SHIELD",
	name = "steel shield", short_name = "steel",
	level_range = {10, 20},
	require = { stat = { str=16 }, },
	cost = 30,
	material_level = 2,
	special_combat = {
		dam = resolvers.cbonus(10),
		block = resolvers.cbonus(40),
		max_acc = 75,
		critical_power = 1.1,
		dammod = {str=0.4},
	},
	wielder = {
		learn_talent = {
			[Talents.T_BLOCK] = 2,
		},
		fatigue = 8,
	},
}

newEntity{ base = "BASE_SHIELD",
	name = "dwarven-steel shield", short_name = "d.steel",
	level_range = {20, 30},
	require = { stat = { str=24 }, },
	cost = 80,
	material_level = 3,
	special_combat = {
		dam = resolvers.cbonus(20),
		block = resolvers.cbonus(80),
		max_acc = 75,
		critical_power = 1.1,
		dammod = {str=0.6},
	},
	wielder = {
		learn_talent = {
			[Talents.T_BLOCK] = 3,
		},
		fatigue = 12,
	},
}

newEntity{ base = "BASE_SHIELD",
	name = "stralite shield", short_name = "stralite",
	level_range = {30, 40},
	require = { stat = { str=35 }, },
	cost = 120,
	material_level = 4,
	special_combat = {
		dam = resolvers.cbonus(35),
		block = resolvers.cbonus(140),
		max_acc = 75,
		critical_power = 1.1,
		dammod = {str=0.8},
	},
	wielder = {
		learn_talent = {
			[Talents.T_BLOCK] = 4,
		},
		fatigue = 14,
	},
}

newEntity{ base = "BASE_SHIELD",
	name = "voratun shield", short_name = "voratun",
	level_range = {40, 50},
	require = { stat = { str=48 }, },
	cost = 170,
	material_level = 5,
	special_combat = {
		dam = resolvers.cbonus(50),
		block = resolvers.cbonus(200),
		max_acc = 75,
		critical_power = 1.1,
		dammod = {str=1},
	},
	wielder = {
		learn_talent = {
			[Talents.T_BLOCK] = 5,
		},
		fatigue = 14,
	},
}
