newEntity{
	define_as = "BASE_GREATSWORD",
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="greatsword",
	display = "/", color=colors.SLATE,
	encumber = 3,
	rarity = 3,
	desc = [[Massive two-handed swords.]],
	egos = "/data/general/objects/egos.lua", egos_chance = resolvers.mbonus(40, 5),
}

newEntity{ base = "BASE_GREATSWORD",
	name = "iron greatsword",
	level_range = {1, 10},
	require = { stat = { str=11 }, },
	cost = 5,
	combat = {
		dam = resolvers.rngavg(12,20),
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
	combat = {
		dam = resolvers.rngavg(25,35),
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
	combat = {
		dam = resolvers.rngavg(40,50),
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
	combat = {
		dam = resolvers.rngavg(60,70),
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
	combat = {
		dam = resolvers.rngavg(85, 95),
		apr = 4,
		physcrit = 5,
		dammod = {str=1.2},
	},
}
