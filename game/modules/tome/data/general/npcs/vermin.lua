local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_WORM",
	type = "vermin", subtype = "worms",
	display = "w", color=colors.WHITE,
	can_multiply = 4,
	body = { INVEN = 10 },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	energy = { mod=0.9 },
	stats = { str=10, dex=15, mag=3, con=3 },
	combat_armor = 1, combat_def = 1,
}

newEntity{ base = "BASE_NPC_WORM",
	name = "white worm mass", color=colors.WHITE,
	level_range = {1, 15}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=1, atk=15, apr=100 },

	resolvers.talents{ [Talents.T_CRAWL_POISON]=1, [Talents.T_MULTIPLY]=1 },
}

newEntity{ base = "BASE_NPC_WORM",
	name = "green worm mass", color=colors.GREEN,
	level_range = {2, 15}, exp_worth = 1,
	rarity = 5,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=1, atk=15, apr=100 },

	resolvers.talents{ [Talents.T_CRAWL_ACID]=2, [Talents.T_MULTIPLY]=1 },
}
