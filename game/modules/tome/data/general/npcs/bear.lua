--updated: 7:59 AM 1/30/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_BEAR",
	type = "animal", subtype = "bear",
	display = "q", color=colors.WHITE,
	body = { INVEN = 10 },

	max_stamina = 100,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=5, },
	energy = { mod=0.9 },
	stats = { str=18, dex=13, mag=5, con=15 },

	combat_armor = 1, combat_def = 1,
	combat = { dam=resolvers.rngavg(12,25), atk=10, apr=3, physspeed=2 },
	life_rating = 12,
	resolvers.tmasteries{ ["technique/other"]=0.25 },

	resists = { [DamageType.FIRE] = 20, [DamageType.COLD] = 20, [DamageType.POISON] = 20 },
}

newEntity{ base = "BASE_NPC_BEAR",
	name = "brown bear", color=colors.UMBER,
	desc = [[The weakest of bears, covered in brown shaggy fur.]],
	level_range = {5, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(80,90),
	combat_armor = 7, combat_def = 3,
	resolvers.talents{ [Talents.T_STUN]=1 },
}

newEntity{ base = "BASE_NPC_BEAR",
	name = "black bear", color={0,0,0},
	desc = [[Do you smell like honey? 'cause this bear wants honey.]],
	level_range = {6, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 8, combat_def = 3,
	resolvers.talents{ [Talents.T_STUN]=1 },
}

newEntity{ base = "BASE_NPC_BEAR",
	name = "cave bear", color=colors.DARK_SLATE_GRAY,
	desc = [[It has come down from its cave foraging for food. Unfortunately, it found you.]],
	level_range = {7, 50}, exp_worth = 1,
	rarity = 8,
	max_life = resolvers.rngavg(100,110),
	combat_armor = 9, combat_def = 4,
	combat = { dam=resolvers.rngavg(13,17), atk=7, apr=2, physspeed=2 },
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=2, [Talents.T_KNOCKBACK]=1,},
}

newEntity{ base = "BASE_NPC_BEAR",
	name = "war bear", color=colors.DARK_UMBER,
	desc = [[Bears with tusks, trained to kill.]],
	level_range = {7, 50}, exp_worth = 1,
	rarity = 8,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 9, combat_def = 4,
	combat = { dam=resolvers.rngavg(13,17), atk=10, apr=3, physspeed=2 },
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=2, [Talents.T_KNOCKBACK]=1,},
}

newEntity{ base = "BASE_NPC_BEAR",
	name = "grizzly bear", color=colors.LIGHT_UMBER,
	desc = [[A huge, beastly bear, more savage than most of its kind.]],
	level_range = {10, 50}, exp_worth = 1,
	rarity = 9,
	max_life = resolvers.rngavg(110,120),
	combat_armor = 10, combat_def = 5,
	combat = { dam=resolvers.rngavg(15,20), atk=10, apr=3, physspeed=2 },
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=3, [Talents.T_KNOCKBACK]=2,},
}

newEntity{ base = "BASE_NPC_BEAR",
	name = "polar bear", color=colors.WHITE,
	desc = [[This huge white bear has wandered south in search of food.]],
	level_range = {12, 50}, exp_worth = 1,
	rarity = 11,
	max_life = resolvers.rngavg(110,120),
	combat_armor = 10, combat_def = 7,
	combat = { dam=resolvers.rngavg(15,20), atk=12, apr=3, physspeed=2 },
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=3, [Talents.T_KNOCKBACK]=2,},
	resists = { [DamageType.COLD] = 100, },
}
