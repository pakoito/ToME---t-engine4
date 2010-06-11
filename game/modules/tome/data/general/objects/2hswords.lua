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
	define_as = "BASE_GREATSWORD",
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="greatsword",
	add_name = " (#COMBAT#)",
	display = "/", color=colors.SLATE,
	encumber = 3,
	rarity = 5,
	combat = { talented = "sword", damrange = 1.6, sound = "actions/melee", sound_miss = "actions/melee_miss", },
	desc = [[Massive two-handed swords.]],
	twohanded = true,
	egos = "/data/general/objects/egos/weapon.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_GREATSWORD",
	name = "iron greatsword",
	level_range = {1, 10},
	require = { stat = { str=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		dam = resolvers.rngavg(8,14),
		apr = 1,
		physcrit = 2.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_GREATSWORD",
	name = "steel greatsword",
	level_range = {10, 20},
	require = { stat = { str=16 }, },
	cost = 10,
	material_level = 2,
	combat = {
		dam = resolvers.rngavg(18,26),
		apr = 2,
		physcrit = 3,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_GREATSWORD",
	name = "dwarven-steel greatsword",
	level_range = {20, 30},
	require = { stat = { str=24 }, },
	cost = 15,
	material_level = 3,
	combat = {
		dam = resolvers.rngavg(32,40),
		apr = 2,
		physcrit = 3.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_GREATSWORD",
	name = "galvorn greatsword",
	level_range = {30, 40},
	require = { stat = { str=35 }, },
	cost = 25,
	material_level = 4,
	combat = {
		dam = resolvers.rngavg(45,52),
		apr = 3,
		physcrit = 4.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_GREATSWORD",
	name = "mithril greatsword",
	level_range = {40, 50},
	require = { stat = { str=48 }, },
	cost = 35,
	material_level = 5,
	combat = {
		dam = resolvers.rngavg(58, 66),
		apr = 4,
		physcrit = 5,
		dammod = {str=1.2},
	},
}
