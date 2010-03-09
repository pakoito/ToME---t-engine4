newEntity{
	define_as = "BASE_LONGBOW",
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="longbow",
	display = "}", color=colors.UMBER,
	encumber = 4,
	rarity = 3,
	combat = { talented = "bow", damrange = 1.4},
	archery = "bow",
	desc = [[Longbows are used to shoot arrows at your foes.]],
}

newEntity{ base = "BASE_LONGBOW",
	name = "elm longbow",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 5,
	combat = {
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_LONGBOW",
	name = "ash longbow",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 10,
	combat = {
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_LONGBOW",
	name = "yew longbow",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 15,
	combat = {
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_LONGBOW",
	name = "elven-wood longbow",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 25,
	combat = {
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_LONGBOW",
	name = "dragonbone longbow",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 35,
	combat = {
		physspeed = 0.8,
	},
}

------------------ AMMO -------------------

newEntity{
	define_as = "BASE_ARROW",
	slot = "QUIVER",
	type = "ammo", subtype="arrow",
	add_name = " (#COMBAT#)",
	display = "{", color=colors.UMBER,
	encumber = 0.03,
	rarity = 3,
	combat = { talented = "bow", damrange = 1.4},
	archery_ammo = "bow",
	desc = [[Arrows are used with bows to pierce your foes to death.]],
	generate_stack = resolvers.rngavg(100,200),
	stacking = true,
}

newEntity{ base = "BASE_ARROW",
	name = "elm arrow",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 0.05,
	combat = {
		dam = resolvers.rngavg(7,12),
		apr = 5,
		physcrit = 1,
		dammod = {dex=0.7, str=0.5},
	},
}

newEntity{ base = "BASE_ARROW",
	name = "ash arrow",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 0.1,
	combat = {
		dam = resolvers.rngavg(15,22),
		apr = 7,
		physcrit = 1.5,
		dammod = {dex=0.7, str=0.5},
	},
}

newEntity{ base = "BASE_ARROW",
	name = "yew arrow",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 0.15,
	combat = {
		dam = resolvers.rngavg(28,37),
		apr = 10,
		physcrit = 2,
		dammod = {dex=0.7, str=0.5},
	},
}

newEntity{ base = "BASE_ARROW",
	name = "elven-wood arrow",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 0.25,
	combat = {
		dam = resolvers.rngavg(40,47),
		apr = 14,
		physcrit = 2.5,
		dammod = {dex=0.7, str=0.5},
	},
}

newEntity{ base = "BASE_ARROW",
	name = "dragonbone arrow",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 0.35,
	combat = {
		dam = resolvers.rngavg(50, 57),
		apr = 18,
		physcrit = 3,
		dammod = {dex=0.7, str=0.5},
	},
}
