local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_MOLD",
	type = "immovable", subtype = "molds",
	display = "m", color=colors.WHITE,
	desc = "A strange growth on the dungeon floor.",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	stats = { str=10, dex=15, mag=3, con=3 },
	energy = { mod=0.5 },
	combat_armor = 1, combat_def = 1,
	never_move = true,
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "grey mold", color=colors.SLATE,
	desc = "A strange brey growth on the dungeon floor.",
	level_range = {1, 5}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=10 },
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "brown mold", color=colors.UMBER,
	desc = "A strange brown growth on the dungeon floor.",
	level_range = {2, 5}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=10 },
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "shining mold", color=colors.YELLOW,
	desc = "A strange luminescent growth on the dungeon floor.",
	level_range = {3, 15}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(1,1),
	combat = { dam=5, atk=15, apr=10 },

	talents = resolvers.talents{ [Talents.T_SPORE_BLIND]=1 },
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "green mold", color=colors.GREEN,
	desc = "A strange sickly green growth on the dungeon floor.",
	level_range = {5, 15}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=10 },
	talents = resolvers.talents{ [Talents.T_SPORE_POISON]=1 },
}
