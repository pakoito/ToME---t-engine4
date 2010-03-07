newEntity{
	define_as = "BASE_SLING",
	slot = "MAINHAND",
	type = "weapon", subtype="sling",
	display = "}", color=colors.UMBER,
	encumber = 4,
	rarity = 3,
	combat = { talented = "sling", },
	archery = "sling",
	desc = [[Slings are used to shoot peebles at your foes.]],
}

newEntity{ base = "BASE_SLING",
	name = "elm sling",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 5,
	combat = {
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_SLING",
	name = "ash sling",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 10,
	combat = {
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_SLING",
	name = "yew sling",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 15,
	combat = {
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_SLING",
	name = "elven-wood sling",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 25,
	combat = {
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_SLING",
	name = "dragonbone sling",
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
	rarity = 3,
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
	cost = 5,
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
	cost = 10,
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
	cost = 15,
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
	cost = 25,
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
	cost = 35,
	combat = {
		dam = resolvers.rngavg(50, 57),
		apr = 6,
		physcrit = 7,
		dammod = {dex=0.7, cun=0.5},
	},
}
