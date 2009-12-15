newEntity{
	define_as = "BASE_SWORD",
	slot = "MAINHAND",
	type = "weapon", subtype="sword",
	display = "/", color=colors.SLATE,
	encumber = 3,
	desc = [[Sharp, long, and deadly.]],
}

newEntity{ base = "BASE_SWORD",
	name = "rapier",
	level_range = {1, 10},
	rarity = 3,
	combat = {
		dam = resolvers.rngavg(7,11),
		apr = 3,
		dammod = {str=1},
	},
}

newEntity{ base = "BASE_SWORD",
	name = "rapier",
	level_range = {1, 10},
	rarity = 3,
	combat = {
		dam = resolvers.rngavg(10,20),
		apr = 3,
		dammod = {str=1},
	},
}
