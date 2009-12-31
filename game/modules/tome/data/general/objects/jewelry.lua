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
	display = "=",
	encumber = 0.1,
	rarity = 8,
	desc = [[Amulets can have magical properties.]],
	egos = "/data/general/objects/egos/amulets.lua", egos_chance = resolvers.mbonus(30, 80),
}

newEntity{ base = "BASE_RING",
	name = "copper ring", color = colors.UMBER,
	level_range = {1, 10},
	cost = 1,
}
newEntity{ base = "BASE_RING",
	name = "steel ring", color = colors.SLATE,
	level_range = {10, 20},
	cost = 1,
}
newEntity{ base = "BASE_RING",
	name = "gold ring", color = colors.YELLOW,
	level_range = {20, 30},
	cost = 1,
}
newEntity{ base = "BASE_RING",
	name = "galvorn ring", color = {r=50, g=50, b=50},
	level_range = {30, 40},
	cost = 1,
}
newEntity{ base = "BASE_RING",
	name = "mithril ring", color = colors.WHITE,
	level_range = {40, 50},
	cost = 1,
}

newEntity{ base = "BASE_AMULET",
	name = "copper amulet", color = colors.UMBER,
	level_range = {1, 10},
	cost = 1,
}
newEntity{ base = "BASE_AMULET",
	name = "steel amulet", color = colors.SLATE,
	level_range = {10, 20},
	cost = 1,
}
newEntity{ base = "BASE_AMULET",
	name = "gold amulet", color = colors.YELLOW,
	level_range = {20, 30},
	cost = 1,
}
newEntity{ base = "BASE_AMULET",
	name = "galvorn amulet", color = {r=50, g=50, b=50},
	level_range = {30, 40},
	cost = 1,
}
newEntity{ base = "BASE_AMULET",
	name = "mithril amulet", color = colors.WHITE,
	level_range = {40, 50},
	cost = 1,
}
