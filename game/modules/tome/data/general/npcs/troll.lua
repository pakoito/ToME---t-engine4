local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_TROLL",
	type = "giant", subtype = "troll",
	display = "T", color=colors.UMBER,

	combat = { dam=resolvers.rngavg(15,20), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=60, nb=1, {type="money"} },

	life_rating = 15,
	life_regen = 2,
	max_stamina = 90,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=5, },
	energy = { mod=1 },
	stats = { str=20, dex=8, mag=6, con=16 },

	resolvers.tmasteries{ ["technique/other"]=0.3 },

	resists = { [DamageType.FIRE] = -50 },
	fear_immune = 1,
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "forest troll", color=colors.YELLOW_GREEN,
	desc = [[Green-skinned and ugly, this massive humanoid glares at you, clenching wart-covered green fists.]],
	level_range = {1, 50}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 4, combat_def = 0,
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "stone troll", color=colors.DARK_SLATE_GRAY,
	desc = [[A giant troll with scabrous black skin. With a shudder, you notice the belt of dwarf skulls around his massive waist.]],
	level_range = {3, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(120,140),
	combat_armor = 7, combat_def = 0,
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=1, },
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "cave troll", color=colors.SLATE,
	desc = [[This huge troll wields a massive spear and has a disturbingly intelligent look in its piggy eyes.]],
	level_range = {7, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(120,140),
	combat_armor = 9, combat_def = 3,
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=1, [Talents.T_KNOCKBACK]=1,},
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "mountain troll", color=colors.UMBER,
	desc = [[A large and athletic troll with an extremely tough and warty hide.]],
	level_range = {12, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(120,140),
	combat_armor = 12, combat_def = 4,
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=1, [Talents.T_KNOCKBACK]=1, },
}
