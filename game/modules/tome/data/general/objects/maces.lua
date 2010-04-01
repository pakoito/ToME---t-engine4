newEntity{
	define_as = "BASE_MACE",
	slot = "MAINHAND",
	type = "weapon", subtype="mace",
	add_name = " (#COMBAT#)",
	display = "/", color=colors.SLATE,
	encumber = 3,
	rarity = 5,
	combat = { talented = "mace", damrange = 1.4},
	desc = [[Blunt and deadly.]],
	egos = "/data/general/objects/egos/weapon.lua", egos_chance = resolvers.mbonus(40, 5),
}

newEntity{ base = "BASE_MACE",
	name = "iron mace",
	level_range = {1, 10},
	require = { stat = { str=11 }, },
	cost = 5,
	combat = {
		dam = resolvers.rngavg(6,9),
		apr = 2,
		physcrit = 0.5,
		dammod = {str=1},
	},
}

newEntity{ base = "BASE_MACE",
	name = "steel mace",
	level_range = {10, 20},
	require = { stat = { str=16 }, },
	cost = 10,
	combat = {
		dam = resolvers.rngavg(11,17),
		apr = 3,
		physcrit = 1,
		dammod = {str=1},
	},
}

newEntity{ base = "BASE_MACE",
	name = "dwarven-steel mace",
	level_range = {20, 30},
	require = { stat = { str=24 }, },
	cost = 15,
	combat = {
		dam = resolvers.rngavg(22,28),
		apr = 4,
		physcrit = 1.5,
		dammod = {str=1},
	},
}

newEntity{ base = "BASE_MACE",
	name = "galvorn mace",
	level_range = {30, 40},
	require = { stat = { str=35 }, },
	cost = 25,
	combat = {
		dam = resolvers.rngavg(33,40),
		apr = 5,
		physcrit = 2.5,
		dammod = {str=1},
	},
}

newEntity{ base = "BASE_MACE",
	name = "mithril mace",
	level_range = {40, 50},
	require = { stat = { str=48 }, },
	cost = 35,
	combat = {
		dam = resolvers.rngavg(43,48),
		apr = 6,
		physcrit = 3,
		dammod = {str=1},
	},
}
