local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SKELETON",
	type = "undead", subtype = "skeletons",
	display = "s", color=colors.WHITE,

	combat = { dam=1, atk=1, apr=1 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{ {type="weapon", subtype="greatsword"} },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=60, nb=1, {type="money"} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=4, },
	energy = { mod=1 },
	stats = { str=14, dex=12, mag=10, con=12 },

	resolvers.tmasteries{ ["technique/other"]=0.3, ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },

	blind_immune = 1,
	fear_immune = 1,
	see_invisible = 2,
	undead = 1,
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "degenerated skeleton warrior", color=colors.WHITE,
	level_range = {1, 50}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(40,50),
	combat_armor = 5, combat_def = 1,
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "skeleton warrior", color=colors.SLATE,
	level_range = {2, 50}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 5, combat_def = 1,
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUNNING_BLOW]=1, },
	ai_state = { talent_in=1, },
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "skeleton mage", color=colors.LIGHT_RED,
	level_range = {4, 50}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(50,60),
	max_mana = resolvers.rngavg(70,80),
	combat_armor = 3, combat_def = 1,
	stats = { str=10, dex=12, cun=14, mag=14, con=10 },
	resolvers.talents{ [Talents.T_MANA_POOL]=1, [Talents.T_FLAME]=2, [Talents.T_MANATHRUST]=3 },

	equipment = resolvers.equip{ {type="weapon", subtype="staff"} },

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=6, },
}
