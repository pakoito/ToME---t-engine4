newEntity{
	define_as = "BASE_RING",
	slot = "FINGER",
	type = "jewelry", subtype="ring",
	display = "=",
	encumber = 0.1,
	rarity = 6,
	desc = [[Rings can have magical properties.]],
	-- Most rings are ego items
	egos = "/data/general/objects/egos/rings.lua", egos_chance = resolvers.mbonus(30, 80),
}
newEntity{
	define_as = "BASE_AMULET",
	slot = "NECK",
	type = "jewelry", subtype="amulet",
	display = '"',
	encumber = 0.1,
	rarity = 8,
	desc = [[Amulets can have magical properties.]],
	egos = "/data/general/objects/egos/amulets.lua", egos_chance = resolvers.mbonus(30, 80),
}

newEntity{ base = "BASE_RING",
	name = "copper ring", color = colors.UMBER,
	unided_name = "copper ring",
	level_range = {1, 10},
	cost = 1,
}
newEntity{ base = "BASE_RING",
	name = "steel ring", color = colors.SLATE,
	unided_name = "steel ring",
	level_range = {10, 20},
	cost = 1,
}
newEntity{ base = "BASE_RING",
	name = "gold ring", color = colors.YELLOW,
	unided_name = "gold ring",
	level_range = {20, 30},
	cost = 1,
}
newEntity{ base = "BASE_RING",
	name = "galvorn ring", color = {r=50, g=50, b=50},
	unided_name = "galvorn ring",
	level_range = {30, 40},
	cost = 1,
}
newEntity{ base = "BASE_RING",
	name = "mithril ring", color = colors.WHITE,
	unided_name = "mithril ring",
	level_range = {40, 50},
	cost = 1,
}

newEntity{ base = "BASE_AMULET",
	name = "copper amulet", color = colors.UMBER,
	unided_name = "copper amulet",
	level_range = {1, 10},
	cost = 1,
}
newEntity{ base = "BASE_AMULET",
	name = "steel amulet", color = colors.SLATE,
	unided_name = "steel amulet",
	level_range = {10, 20},
	cost = 1,
}
newEntity{ base = "BASE_AMULET",
	name = "gold amulet", color = colors.YELLOW,
	unided_name = "gold amulet",
	level_range = {20, 30},
	cost = 1,
}
newEntity{ base = "BASE_AMULET",
	name = "galvorn amulet", color = {r=50, g=50, b=50},
	unided_name = "galvorn amulet",
	level_range = {30, 40},
	cost = 1,
}
newEntity{ base = "BASE_AMULET",
	name = "mithril amulet", color = colors.WHITE,
	unided_name = "mithril amulet",
	level_range = {40, 50},
	cost = 1,
}
