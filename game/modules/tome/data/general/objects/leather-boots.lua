newEntity{
	define_as = "BASE_LEATHER_BOOT",
	slot = "FEET",
	type = "armor", subtype="feet",
	add_name = " (#ARMOR#)",
	display = "]", color=colors.UMBER,
	encumber = 2,
	rarity = 6,
	desc = [[A pair of boots made of leather.]],
}

newEntity{ base = "BASE_LEATHER_BOOT",
	name = "pair of rough leather boots",
	level_range = {1, 20},
	cost = 2,
	wielder = {
		combat_armor = 1,
		fatigue = 1,
	},
}

newEntity{ base = "BASE_LEATHER_BOOT",
	name = "pair of hardened leather boots",
	level_range = {20, 40},
	cost = 4,
	wielder = {
		combat_armor = 3,
		fatigue = 3,
	},
}

newEntity{ base = "BASE_LEATHER_BOOT",
	name = "pair of drakeskin leather boots",
	level_range = {40, 50},
	cost = 7,
	wielder = {
		combat_armor = 5,
		fatigue = 5,
	},
}
