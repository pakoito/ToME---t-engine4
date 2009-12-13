newEntity{
	define_as = "BASE_SWORD",
	slot = "MAINHAND",
	type = "weapon",
	display = "/", color_r=255,
	encumber = 3,
	egos_chance = { },
	egos = loadList("/data/general/egos.lua"),
}

newEntity{
	base = "BASE_SWORD",
	name = "& #1#longsword~#2#",
	level_range = {1, 10},
	rarity = 3,
	combat = {
		dam = resolvers.rngavg(7,11),
		atk = 3,
		apr = 2,
		dammod = {str=1},
	},
	wielder = {
	},
}

newEntity{
	name = "& tower shield~",
	display = "[", color_r=255,
	level_range = {1, 10},
	rarity = 2,
	encumber = 6,
	wielder = {
		combat_def = 6,
		combat_armor = 1,
	},
}

newEntity{
	name = "& staff~ of fire",
	type = "weapon",
	display = "/", color_b=255,
	level_range = {1, 10},
	rarity = 2,
	encumber = 4,
	combat = {
		dam = 1,
		atk = 1,
		apr = 0,
		dammod = {wil=1},
	},
	wielder = {
		stats = {mag=3, wil=2},
	}
}

newEntity{
	name = "& Staff of Olorin",
	type = "weapon",
	display = "/", color_r=255, color_b=255,
	level_range = {10,10},
	rarity = 15,
	encumber = 3,
	unique = "STAFF_OLORIN",
	combat = {
		dam = 3,
		atk = 1,
		apr = 0,
		dammod = {wil=1},
	},
	wielder = {
		stats = {mag=3, wil=2},
	}
}
