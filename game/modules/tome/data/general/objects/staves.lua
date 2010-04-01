newEntity{
	define_as = "BASE_STAFF",
	slot = "MAINHAND",
	type = "weapon", subtype="staff",
	add_name = " (#COMBAT#)",
	display = "\\", color=colors.LIGHT_RED,
	encumber = 5,
	rarity = 4,
	desc = [[Staves designed for wielders of magic, by the greats of the art.]],
	egos = "/data/general/objects/egos/staves.lua", egos_chance = resolvers.mbonus(40, 5),
}

newEntity{ base = "BASE_STAFF",
	name = "elm staff",
	level_range = {1, 10},
	require = { stat = { mag=11 }, },
	cost = 5,
	combat = {
		dam = resolvers.rngavg(3,5),
		apr = 2,
		physcrit = 2.5,
		dammod = {mag=1},
	},
	wielder = {
		combat_spellpower = 1,
		combat_spellcrit = 1,
	},
}

newEntity{ base = "BASE_STAFF",
	name = "ash staff",
	level_range = {10, 20},
	require = { stat = { mag=16 }, },
	cost = 10,
	combat = {
		dam = resolvers.rngavg(7,11),
		apr = 3,
		physcrit = 3,
		dammod = {mag=1},
	},
	wielder = {
		combat_spellpower = 2,
		combat_spellcrit = 2,
	},
}

newEntity{ base = "BASE_STAFF",
	name = "yew staff",
	level_range = {20, 30},
	require = { stat = { mag=24 }, },
	cost = 15,
	combat = {
		dam = resolvers.rngavg(14,22),
		apr = 4,
		physcrit = 3.5,
		dammod = {mag=1},
	},
	wielder = {
		combat_spellpower = 3,
		combat_spellcrit = 3,
	},
}

newEntity{ base = "BASE_STAFF",
	name = "elven-wood staff",
	level_range = {30, 40},
	require = { stat = { mag=35 }, },
	cost = 25,
	combat = {
		dam = resolvers.rngavg(24,28),
		apr = 5,
		physcrit = 4.5,
		dammod = {mag=1},
	},
	wielder = {
		combat_spellpower = 4,
		combat_spellcrit = 4,
	},
}

newEntity{ base = "BASE_STAFF",
	name = "dragonbone staff",
	level_range = {40, 50},
	require = { stat = { mag=48 }, },
	cost = 35,
	combat = {
		dam = resolvers.rngavg(32,38),
		apr = 6,
		physcrit = 5,
		dammod = {mag=1},
	},
	wielder = {
		combat_spellpower = 7,
		combat_spellcrit = 5,
	},
}
