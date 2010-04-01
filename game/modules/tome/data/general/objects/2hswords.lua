newEntity{
	define_as = "BASE_GREATSWORD",
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="greatsword",
	add_name = " (#COMBAT#)",
	display = "/", color=colors.SLATE,
	encumber = 3,
	rarity = 5,
	combat = { talented = "sword", damrange = 1.6 },
	desc = [[Massive two-handed swords.]],
	twohanded = true,
	egos = "/data/general/objects/egos/weapon.lua", egos_chance = resolvers.mbonus(40, 5),
}

newEntity{ base = "BASE_GREATSWORD",
	name = "iron greatsword",
	level_range = {1, 10},
	require = { stat = { str=11 }, },
	cost = 5,
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
	combat = {
		dam = resolvers.rngavg(58, 66),
		apr = 4,
		physcrit = 5,
		dammod = {str=1.2},
	},
}
