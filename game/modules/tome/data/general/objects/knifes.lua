newEntity{
	define_as = "BASE_KNIFE",
	slot = "MAINHAND", offslot = "OFFHAND",
	type = "weapon", subtype="dagger",
	display = "/", color=colors.WHITE,
	encumber = 1,
	rarity = 3,
	combat = { talented = "knife", },
	desc = [[Sharp, long, and deadly.]],
--	egos = "/data/general/objects/egos/swords.lua", egos_chance = resolvers.mbonus(40, 5),
}

newEntity{ base = "BASE_KNIFE",
	name = "iron dagger",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 5,
	combat = {
		dam = resolvers.rngavg(4,6),
		apr = 5,
		physcrit = 4,
		dammod = {dex=1},
	},
}

newEntity{ base = "BASE_KNIFE",
	name = "steel dagger",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 10,
	combat = {
		dam = resolvers.rngavg(8,15),
		apr = 6,
		physcrit = 5,
		dammod = {dex=1},
	},
}

newEntity{ base = "BASE_KNIFE",
	name = "dwarven-steel dagger",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 15,
	combat = {
		dam = resolvers.rngavg(18,25),
		apr = 7,
		physcrit = 6,
		dammod = {dex=1},
	},
}

newEntity{ base = "BASE_KNIFE",
	name = "galvorn dagger",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 25,
	combat = {
		dam = resolvers.rngavg(38,45),
		apr = 9,
		physcrit = 8,
		dammod = {dex=1},
	},
}

newEntity{ base = "BASE_KNIFE",
	name = "mithril dagger",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 35,
	combat = {
		dam = resolvers.rngavg(48,55),
		apr = 9,
		physcrit = 10,
		dammod = {dex=1},
	},
}
