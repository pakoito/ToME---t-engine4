newEntity{
	define_as = "BASE_BATTLEAXE",
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="battleaxe",
	add_name = " (#COMBAT#)",
	display = "/", color=colors.SLATE,
	encumber = 3,
	rarity = 3,
	combat = { talented = "axe", damrange = 1.5 },
	desc = [[Massive two-handed battleaxes.]],
	twohanded = true,
}

newEntity{ base = "BASE_BATTLEAXE",
	name = "iron battleaxe",
	level_range = {1, 10},
	require = { stat = { str=11 }, },
	cost = 5,
	combat = {
		dam = resolvers.rngavg(6,12),
		apr = 1,
		physcrit = 4.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_BATTLEAXE",
	name = "steel battleaxe",
	level_range = {10, 20},
	require = { stat = { str=16 }, },
	cost = 10,
	combat = {
		dam = resolvers.rngavg(15,23),
		apr = 2,
		physcrit = 5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_BATTLEAXE",
	name = "dwarven-steel battleaxe",
	level_range = {20, 30},
	require = { stat = { str=24 }, },
	cost = 15,
	combat = {
		dam = resolvers.rngavg(28,35),
		apr = 2,
		physcrit = 6.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_BATTLEAXE",
	name = "galvorn battleaxe",
	level_range = {30, 40},
	require = { stat = { str=35 }, },
	cost = 25,
	combat = {
		dam = resolvers.rngavg(40,48),
		apr = 3,
		physcrit = 7.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_BATTLEAXE",
	name = "mithril battleaxe",
	level_range = {40, 50},
	require = { stat = { str=48 }, },
	cost = 35,
	combat = {
		dam = resolvers.rngavg(54, 60),
		apr = 4,
		physcrit = 8,
		dammod = {str=1.2},
	},
}
