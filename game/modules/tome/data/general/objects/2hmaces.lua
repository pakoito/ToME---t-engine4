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
	define_as = "BASE_GREATMAUL",
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="greatmaul",
	add_name = " (#COMBAT#)",
	display = "\\", color=colors.SLATE,
	encumber = 5,
	rarity = 5,
	combat = { talented = "mace", damrange = 1.5, physspeed=1.2 },
	desc = [[Massive two-handed maul.]],
	twohanded = true,
	egos = "/data/general/objects/egos/weapon.lua", egos_chance = resolvers.mbonus(40, 5),
}

newEntity{ base = "BASE_GREATMAUL",
	name = "iron greatmaul",
	level_range = {1, 10},
	require = { stat = { str=11 }, },
	cost = 5,
	combat = {
		dam = resolvers.rngavg(10,16),
		apr = 1,
		physcrit = 0.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	name = "steel greatmaul",
	level_range = {10, 20},
	require = { stat = { str=16 }, },
	cost = 10,
	combat = {
		dam = resolvers.rngavg(22,30),
		apr = 2,
		physcrit = 1,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	name = "dwarven-steel greatmaul",
	level_range = {20, 30},
	require = { stat = { str=24 }, },
	cost = 15,
	combat = {
		dam = resolvers.rngavg(38,45),
		apr = 2,
		physcrit = 1.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	name = "galvorn greatmaul",
	level_range = {30, 40},
	require = { stat = { str=35 }, },
	cost = 25,
	combat = {
		dam = resolvers.rngavg(50,59),
		apr = 3,
		physcrit = 2.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	name = "mithril greatmaul",
	level_range = {40, 50},
	require = { stat = { str=48 }, },
	cost = 35,
	combat = {
		dam = resolvers.rngavg(62, 72),
		apr = 4,
		physcrit = 3,
		dammod = {str=1.2},
	},
}
