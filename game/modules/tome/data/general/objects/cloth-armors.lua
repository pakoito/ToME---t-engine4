newEntity{
	define_as = "BASE_CLOTH_ARMOR",
	slot = "BODY",
	type = "armor", subtype="cloth",
	add_name = " (#ARMOR#)",
	display = "[", color=colors.SLATE,
	encumber = 2,
	rarity = 5,
	desc = [[A cloth vestment. It offers no intrinsinc protection but can be enchanted.]],
	egos = "/data/general/objects/egos/robe.lua", egos_chance = resolvers.mbonus(30, 15),
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	name = "robe",
	level_range = {1, 50},
	cost = 0.5,
}
