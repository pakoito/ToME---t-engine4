newEntity{
	define_as = "BASE_SWORD",
	type = "weapon",
	display = "\\", color_r=255,
	encumber = 3,
	egos_chance = { },
	egos = loadList("/data/general/egos.lua"),
}

newEntity{
	base = "BASE_SWORD",
	name = "& #1#longsword~#2#",
	level_range = {1, 10},
	rarity = 3,
	wielder = {
		combat_dam=resolvers.rngavg(7,11),
	},
}

newEntity{
	name = "& tower shield~",
	display = "[", color_r=255,
	level_range = {1, 10},
	encumber = 6,
	wielder = {
		combat_def=6,
	},
}

newEntity{
	name = "& staff~ of fire",
	type = "weapon",
	display = "/", color_b=255,
	level_range = {1, 10},
	encumber = 4,
	wielder = {
		combat_dam=3,
		stats = {mag=3, wil=2},
	}
}

newEntity{
	name = "& Staff of Olorin",
	type = "weapon",
	display = "/", color_r=255, color_b=255,
	level_range = {10,10},
	encumber = 3,
	unique = "STAFF_OLORIN",
	wielder = {
		combat_dam=3,
		stats = {mag=3, wil=2},
	}
}
