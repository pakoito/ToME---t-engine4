newEntity{
	define_as = "BASE_LEATHER_CAP",
	slot = "BODY",
	type = "armor", subtype="head",
	display = "]", color=colors.UMBER,
	encumber = 2,
	rarity = 6,
	desc = [[A cap made of leather.]],
}

newEntity{ base = "BASE_LEATHER_CAP",
	name = "rough leather cap",
	level_range = {1, 20},
	cost = 2,
	wielder = {
		combat_armor = 1,
		fatigue = 1,
	},
}

newEntity{ base = "BASE_LEATHER_CAP",
	name = "hardened leather cap",
	level_range = {20, 40},
	cost = 4,
	wielder = {
		combat_armor = 3,
		fatigue = 3,
	},
}

newEntity{ base = "BASE_LEATHER_CAP",
	name = "drakeskin leather cap",
	level_range = {40, 50},
	cost = 7,
	wielder = {
		combat_armor = 5,
		fatigue = 5,
	},
}
