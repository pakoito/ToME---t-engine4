local Talents = require("engine.interface.ActorTalents")

newEntity{ --rodent base
	define_as = "BASE_NPC_RODENT",
	type = "vermin", subtype = "rodent",
	display = "r", color=colors.WHITE,
	can_multiply = 2,
	body = { INVEN = 10 },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	energy = { mod=1 },
	stats = { str=8, dex=15, mag=3, con=5 },
	combat_armor = 1, combat_def = 1,
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant white mouse", color=colors.WHITE,
	level_range = {1, 3}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=10 },
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant brown mouse", color=colors.UMBER,
	level_range = {1, 3}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=10 },
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant white rat", color=colors.WHITE,
	level_range = {1, 4}, exp_worth = 1,
	rarity = 5,
	max_life = resolvers.rngavg(15,20),
	combat = { dam=7, atk=15, apr=10 },
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant brown rat", color=colors.UMBER,
	level_range = {1, 4}, exp_worth = 1,
	rarity = 5,
	max_life = resolvers.rngavg(15,20),
	combat = { dam=7, atk=15, apr=10 },
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant rabbit", color=colors.UMBER,
	desc = [[Kill the wabbit, kill the wabbit, kill the wabbbbbiiiiiit.]],
	level_range = {1, 4}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(20,30),
	combat = { dam=8, atk=16, apr=10 },
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant crystal rat", color=colors.PINK,
	desc = [[Instead of fur this rat has crystals growing on its back which provide extra protection.]],
	level_range = {1, 5}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(35,50),
	combat = { dam=7, atk=15, apr=10 },
	combat_armor = 4, combat_def = 2,
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "cute little bunny", color=colors.SALMON,
	desc = [[It looks at you with cute little eyes before jumping at you with razor sharp teeth.]],
	level_range = {1, 15}, exp_worth = 3,
	rarity = 200,
	max_life = resolvers.rngavg(15,20),
	combat = { dam=50, atk=15, apr=10 },
	combat_armor = 1, combat_def = 20,
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant grey mouse", color=colors.SLATE,
	level_range = {1, 3}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=10 },
	talents = resolvers.talents{ [Talents.T_CRAWL_POISON]=1 },
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant grey rat", color=colors.SLATE,
	level_range = {1, 4}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(15,20),
	combat = { dam=7, atk=15, apr=10 },
	talents = resolvers.talents{ [Talents.T_CRAWL_POISON]=1 },
}
