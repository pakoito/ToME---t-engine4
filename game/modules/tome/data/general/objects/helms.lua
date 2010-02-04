local Talents = require "engine.interface.ActorTalents"

newEntity{
	define_as = "BASE_HELM",
	slot = "HEAD",
	type = "armor", subtype="head",
	display = "]", color=colors.SLATE,
	require = { talent = { Talents.T_HEAVY_ARMOUR_TRAINING }, },
	encumber = 3,
	rarity = 7,
	desc = [[A large helmet that can protect the entire head. Ventilation and bad vision can be a problem, however.]],
}

newEntity{ base = "BASE_HELM",
	name = "iron helm",
	level_range = {1, 20},
	cost = 5,
	wielder = {
		combat_armor = 3,
		fatigue = 5,
	},
}

newEntity{ base = "BASE_HELM",
	name = "dwarven-steel helm",
	level_range = {20, 40},
	cost = 7,
	wielder = {
		combat_armor = 4,
		fatigue = 4,
	},
}

newEntity{ base = "BASE_HELM",
	name = "mithril helm",
	level_range = {40, 50},
	cost = 10,
	wielder = {
		combat_armor = 5,
		fatigue = 5,
	},
}
