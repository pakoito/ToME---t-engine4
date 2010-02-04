local Talents = require "engine.interface.ActorTalents"

newEntity{
	define_as = "BASE_HEAVY_BOOTS",
	slot = "HEAD",
	type = "armor", subtype="feet",
	display = "]", color=colors.SLATE,
	require = { talent = { Talents.T_HEAVY_ARMOUR_TRAINING }, },
	encumber = 3,
	rarity = 7,
	desc = [[Heavy boots, with metal strips at the toes, heels and other vulnerable parts, to better protect the wearer's feet from harm.]],
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	name = "pair of iron boots",
	level_range = {1, 20},
	cost = 5,
	wielder = {
		combat_armor = 3,
		fatigue = 2,
	},
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	name = "pair of dwarven-steel boots",
	level_range = {20, 40},
	cost = 7,
	wielder = {
		combat_armor = 4,
		fatigue = 3,
	},
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	name = "pair of mithril boots",
	level_range = {40, 50},
	cost = 10,
	wielder = {
		combat_armor = 5,
		fatigue = 4,
	},
}
