newEntity{
	define_as = "BASE_MASSIVE_ARMOR",
	slot = "BODY",
	type = "armor", subtype="massive",
	display = "[", color=colors.SLATE,
	encumber = 17,
	rarity = 5,
	desc = [[A suit of armour made of metal plates.]],
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	name = "iron plate armour",
	level_range = {1, 10},
	require = { stat = { str=22 }, },
	wielder = {
		combat_def = 3,
		combat_armor = 7,
		fatigue = 20,
	},
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	name = "steel plate armour",
	level_range = {10, 20},
	require = { stat = { str=28 }, },
	wielder = {
		combat_def = 4,
		combat_armor = 9,
		fatigue = 22,
	},
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	name = "dwarven-steel plate armour",
	level_range = {20, 30},
	require = { stat = { str=35 }, },
	wielder = {
		combat_def = 5,
		combat_armor = 11,
		fatigue = 24,
	},
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	name = "galvorn plate armour",
	level_range = {30, 40},
	require = { stat = { str=48 }, },
	wielder = {
		combat_def = 7,
		combat_armor = 13,
		fatigue = 26,
	},
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	name = "mithril plate armour",
	level_range = {40, 50},
	require = { stat = { str=60 }, },
	wielder = {
		combat_def = 9,
		combat_armor = 16,
		fatigue = 26,
	},
}
