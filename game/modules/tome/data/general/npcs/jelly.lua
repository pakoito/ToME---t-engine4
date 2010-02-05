-- last updated:  10:00 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_JELLY",
	type = "immovable", subtype = "jelly",
	display = "j", color=colors.WHITE,
	desc = "A strange blob on the dungeon floor.",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	stats = { str=10, dex=15, mag=3, con=10 },
	energy = { mod=1 },
	combat_armor = 1, combat_def = 1,
	never_move = 1,

	resists = { [DamageType.LIGHT] = -50 },
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "green jelly", color=colors.GREEN,
	desc = "A strange green blob on the dungeon floor.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=5, damtype=DamageType.POISON },
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "red jelly", color=colors.RED,
	desc = "A strange red blob on the dungeon floor.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=5, damtype=DamageType.FIRE },
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "blue jelly", color=colors.BLUE,
	desc = "A strange blue blob on the dungeon floor.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=5, damtype=DamageType.COLD },
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "white jelly", color=colors.WHITE,
	desc = "A strange white blob on the dungeon floor.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=5 },
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "yellow jelly", color=colors.YELLOW,
	desc = "A strange yellow blob on the dungeon floor.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=5, damtype=DamageType.LIGHTNING },
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "black jelly", color=colors.BLACK,
	desc = "A strange black blob on the dungeon floor.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=5, damtype=DamageType.ACID },
}
