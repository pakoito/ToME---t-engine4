newEntity{
	define_as = "BASE_LIGHT_ARMOR",
	slot = "BODY",
	type = "armor", subtype="light",
	display = "[", color=colors.SLATE,
	encumber = 17,
	rarity = 5,
	desc = [[A suit of armour made of leather.]],
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	name = "rough leather armour",
	level_range = {1, 10},
	require = { stat = { str=12 }, },
	cost = 10,
	wielder = {
		combat_def = 1,
		combat_armor = 2,
		fatigue = 6,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	name = "cured leather armour",
	level_range = {10, 20},
	require = { stat = { str=14 }, },
	cost = 12,
	wielder = {
		combat_def = 2,
		combat_armor = 4,
		fatigue = 7,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	name = "hardened leather armour",
	level_range = {20, 30},
	require = { stat = { str=16 }, },
	cost = 15,
	wielder = {
		combat_def = 3,
		combat_armor = 6,
		fatigue = 8,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	name = "reinforced leather armour",
	level_range = {30, 40},
	cost = 20,
	require = { stat = { str=18 }, },
	wielder = {
		combat_def = 4,
		combat_armor = 7,
		fatigue = 8,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	name = "drakeskin leather armour",
	level_range = {40, 50},
	require = { stat = { str=20 }, },
	cost = 25,
	wielder = {
		combat_def = 5,
		combat_armor = 8,
		fatigue = 8,
	},
}

