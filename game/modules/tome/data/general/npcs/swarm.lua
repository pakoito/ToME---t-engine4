--updated 7:33 PM 1/28/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_INSECT",
	type = "insect", subtype = "swarms",
	display = "I", color=colors.WHITE,
	can_multiply = 2,
	desc = "Buzzzzzzzzzzzzzzzzzzzzzzzzzzz.",
	body = { INVEN = 1 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	stats = { str=1, dex=20, mag=3, con=1 },
	energy = { mod=2 },
	combat_armor = 1, combat_def = 10,
}

newEntity{ base = "BASE_NPC_INSECT",
	name = "midge swarm", color=colors.UMBER,
	desc = "A swarm of midges, they want blood.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(1,2),
	combat = { dam=1, atk=15, apr=20 },
}

newEntity{ base = "BASE_NPC_INSECT",
	name = "bee swarm", color=colors.GOLD,
	desc = "They buzz at you threateningly, as you have gotten too close to their hive.",
	level_range = {2, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(1,3),
	combat = { dam=2, atk=15, apr=20 },

	talents = resolvers.talents{ [Talents.T_SPORE_POISON]=1 },
}

newEntity{ base = "BASE_NPC_INSECT",
	name = "hornet swarm", color=colors.YELLOW,
	desc = "You have intruded on their grounds, they will defend it at all costs.",
	level_range = {3, 25}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(3,5),
	combat = { dam=5, atk=15, apr=20 },

	talents = resolvers.talents{ [Talents.T_SPORE_POISON]=2 },
}

newEntity{ base = "BASE_NPC_INSECT",
	name = "hummerhorn", color=colors.YELLOW,
	desc = "A giant buzzing wasp, its stinger drips venom. ",
	level_range = {16, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(5,7),
	combat = { dam=10, atk=15, apr=20 },
	can_multiply = 4,

	talents = resolvers.talents{ [Talents.T_SPORE_POISON]=3 },
}
