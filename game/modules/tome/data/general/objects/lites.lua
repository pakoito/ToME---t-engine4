newEntity{
	define_as = "BASE_LITE",
	slot = "LITE",
	type = "lite", subtype="lite",
	display = "~",
	desc = [[Lite up the dark places of the world!]],
}

newEntity{ base = "BASE_LITE",
	name = "brass lantern", color=colors.LIGHT_UMBER,
	desc = [[A brass container with a wick emerging from it, protected from draughts by a sheet of greased paper. It can be carried by a handle.]],
	level_range = {1, 20},
	rarity = 7,
	encumber = 2,
	cost = 0.5,

	wielder = {
		lite = 2,
	},
}

newEntity{ base = "BASE_LITE",
	name = "dwarven lantern", color=colors.LIGHT_UMBER,
	desc = [[Made by the Dwarves, this lantern provides light in the darkest recesses of the earth.]],
	level_range = {20, 35},
	rarity = 3,
	encumber = 1,
	cost = 2,

	wielder = {
		lite = 3,
	},
}

newEntity{ base = "BASE_LITE",
	name = "faenorian lamp", color=colors.GOLD,
	desc = [[Made by the descendants of the Noldo craftsman, this lamp contains a part of the flame which burned inside Feanor.]],
	level_range = {35, 50},
	rarity = 3,
	encumber = 1,
	cost = 4,

	wielder = {
		lite = 4,
	},
}
