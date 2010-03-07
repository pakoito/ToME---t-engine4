local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SNAKE",
	type = "animal", subtype = "snake",
	display = "J", color=colors.WHITE,
	body = { INVEN = 10 },

	max_stamina = 110,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	energy = { mod=1.3 },
	stats = { str=14, dex=23, mag=5, con=5 },
	combat_armor = 1, combat_def = 1,
}

newEntity{ base = "BASE_NPC_SNAKE",
	name = "large brown snake", color=colors.UMBER,
	desc = [[This large snake hisses at you, angry at being disturbed.]],
	level_range = {1, 50}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(20,30),
	combat_armor = 1, combat_def = 3,
	combat = { dam=2, atk=30, apr=10 },
}

newEntity{ base = "BASE_NPC_SNAKE",
	name = "large white snake", color=colors.WHITE,
	desc = [[This large snake hisses at you, angry at being disturbed.]],
	level_range = {1, 50}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(20,30),
	combat_armor = 1, combat_def = 3,
	combat = { dam=2, atk=30, apr=10 },
}

newEntity{ base = "BASE_NPC_SNAKE",
	name = "copperhead snake", color=colors.SALMON,
	desc = [[It has a copper head and sharp venomous fangs.]],
	level_range = {2, 50}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(30,40),
	combat_armor = 2, combat_def = 5,
	combat = { dam=3, atk=30, apr=10 },

	talents = resolvers.talents{ [Talents.T_BITE_POISON]=1 },
}

newEntity{ base = "BASE_NPC_SNAKE",
	name = "rattlesnake", color=colors.FIREBRICK,
	desc = [[As you approach, the snake coils up and rattles its tail threateningly.]],
	level_range = {4, 50}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(30,50),
	combat_armor = 2, combat_def = 8,
	combat = { dam=5, atk=30, apr=10 },

	talents = resolvers.talents{ [Talents.T_BITE_POISON]=1 },
}

newEntity{ base = "BASE_NPC_SNAKE",
	name = "king cobra", color=colors.GREEN,
	desc = [[It is a large snake with a hooded face.]],
	level_range = {5, 50}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(40,70),
	combat_armor = 3, combat_def = 11,
	combat = { dam=7, atk=30, apr=10 },

	talents = resolvers.talents{ [Talents.T_BITE_POISON]=2 },
}

newEntity{ base = "BASE_NPC_SNAKE",
	name = "black mamba", color=colors.BLACK,
	desc = [[It has glistening black skin, a sleek body, and highly venomous fangs.]],
	level_range = {7, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(50,80),
	combat_armor = 4, combat_def = 12,
	combat = { dam=10, atk=30, apr=10 },

	talents = resolvers.talents{ [Talents.T_BITE_POISON]=3 },
}

newEntity{ base = "BASE_NPC_SNAKE",
	name = "anaconda", color=colors.YELLOW_GREEN,
	desc = [[You recoil in fear as you notice this huge, 10 meter long snake.  It seeks to crush the life out of you.]],
	level_range = {10, 50}, exp_worth = 1,
	rarity = 11,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 14, combat_def = 5,
	combat = { dam=12, atk=10, apr=10 },
	energy = { mod=0.8 },

	talents = resolvers.talents{ [Talents.T_STUN]=5 },
}
