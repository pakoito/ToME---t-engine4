-- last updated:  7:34 PM 2/2/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_PLANT",
	type = "immovable", subtype = "plants",
	display = "#", color=colors.WHITE,
	desc = "A not-so-strange growth on the dungeon floor.",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	stats = { str=10, dex=10, mag=3, con=10 },
	energy = { mod=1 },
	combat_armor = 1, combat_def = 1,
	never_move = 1,
}

newEntity{ base = "BASE_NPC_PLANT",
	name = "giant venus flytrap", color=colors.GREEN,
	desc = "This flesh eating plant has grown to enormous proportions and seeks to quell it hunger",
	level_range = {7, 50}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=10 },
}

newEntity{ base = "BASE_NPC_PLANT",
	name = "huorn", color=colors.GREEN,
	desc = "A very strong near-sentient tree, which has become hostile to other living things.",
	level_range = {12, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(100,130),
	life_rating = 15,
	combat = { dam=resolvers.rngavg(8,13), atk=15, apr=5 },
	never_move = 0,
}

newEntity{ base = "BASE_NPC_PLANT",
	name = "poison ivy", color=colors.GREEN,
	desc = "This harmless little plant makes you all itchy.",
	level_range = {3, 25}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(1,1),
	combat = { dam=3, atk=15, apr=3, DamageType.POISON},
	can_multiply = 2,

	on_melee_hit = {[DamageType.POISON]=5},
}

newEntity{ base = "BASE_NPC_PLANT",
	name = "honey tree", color=colors.UMBER,
	desc = "As you approach it, you hear a high pitched buzzing sound.",
	level_range = {10, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(100,130),
	life_rating = 15,
	combat = { dam=0, atk=0, apr=0 },

	summon = {
		{type="insect", subtype="swarms", name="bee swarm", number=1, hasxp=true},
		{type="insect", subtype="swarms", name="bee swarm", number=1, hasxp=true},
		{type="insect", subtype="swarms", name="bee swarm", number=1, hasxp=true},
		{type="insect", subtype="swarms", name="bee swarm", number=2, hasxp=true},
		{type="insect", subtype="swarms", name="bee swarm", number=2, hasxp=true},
		{type="animal", subtype="bear", number=1, hasxp=true},
	},

	talents = resolvers.talents{ [Talents.T_SUMMON]=1 },
}
