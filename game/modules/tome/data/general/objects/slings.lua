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
	define_as = "BASE_SLING",
	slot = "MAINHAND",
	type = "weapon", subtype="sling",
	display = "}", color=colors.UMBER,
	encumber = 4,
	rarity = 5,
	combat = { talented = "sling", sound = "actions/arrow", sound_miss = "actions/arrow", },
	archery = "sling",
	desc = [[Slings are used to shoot peebles at your foes.]],
}

newEntity{ base = "BASE_SLING",
	name = "rough leather sling",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 5,
	combat = {
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_SLING",
	name = "cured leather sling",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 10,
	combat = {
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_SLING",
	name = "hardened leather sling",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 15,
	combat = {
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_SLING",
	name = "reinforced leather sling",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 25,
	combat = {
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_SLING",
	name = "drakeskin leather sling",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 35,
	combat = {
		physspeed = 0.8,
	},
}

------------------ AMMO -------------------

newEntity{
	define_as = "BASE_SHOT",
	slot = "QUIVER",
	type = "ammo", subtype="shot",
	add_name = " (#COMBAT#)",
	display = "{", color=colors.UMBER,
	encumber = 0.03,
	rarity = 5,
	combat = { talented = "sling", damrange = 1.2},
	archery_ammo = "sling",
	desc = [[Shots are used with slings to pummel your foes to death.]],
	generate_stack = resolvers.rngavg(100,200),
	stacking = true,
}

newEntity{ base = "BASE_SHOT",
	name = "iron shot",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 0.05,
	combat = {
		dam = resolvers.rngavg(7,12),
		apr = 1,
		physcrit = 4,
		dammod = {dex=0.7, cun=0.5},
	},
}

newEntity{ base = "BASE_SHOT",
	name = "steel shot",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 0.10,
	combat = {
		dam = resolvers.rngavg(15,22),
		apr = 2,
		physcrit = 4.5,
		dammod = {dex=0.7, cun=0.5},
	},
}

newEntity{ base = "BASE_SHOT",
	name = "dwarven-steel shot",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 0.15,
	combat = {
		dam = resolvers.rngavg(28,37),
		apr = 3,
		physcrit = 5,
		dammod = {dex=0.7, cun=0.5},
	},
}

newEntity{ base = "BASE_SHOT",
	name = "galvorn shot",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 0.25,
	combat = {
		dam = resolvers.rngavg(40,47),
		apr = 5,
		physcrit = 5.5,
		dammod = {dex=0.7, cun=0.5},
	},
}

newEntity{ base = "BASE_SHOT",
	name = "mithril shot",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 0.35,
	combat = {
		dam = resolvers.rngavg(50, 57),
		apr = 6,
		physcrit = 7,
		dammod = {dex=0.7, cun=0.5},
	},
}
