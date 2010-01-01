local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SKELETON",
	type = "undead", subtype = "skeletons",
	display = "s", color=colors.WHITE,

	combat = { dam=1, atk=1, apr=1 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{ {type="weapon", subtype="longsword"} },
	drops = resolvers.drops{chance=200, nb=10, {} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	energy = { mod=1 },
	stats = { str=14, dex=12, mag=10, con=12 },

	blind_immune = 1,
	see_invisible = 2,
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "degenerated skeleton warrior", color=colors.WHITE,
	level_range = {1, 50}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(30,40),
	combat_armor = 5, combat_def = 1,
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "skeleton warrior", color=colors.SLATE,
	level_range = {2, 50}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(40,50),
	combat_armor = 5, combat_def = 1,
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "skeleton mage", color=colors.LIGHT_RED,
	level_range = {4, 50}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(20,25),
	max_mana = resolvers.rngavg(40,50),
	combat_armor = 3, combat_def = 1,
	stats = { str=10, dex=12, cun=14, mag=14, con=10 },
	talents = resolvers.talents{ Talents.T_MANA_POOL, Talents.T_FLAME, Talents.T_MANATHRUST },

	equipment = resolvers.equip{ {type="weapon", subtype="staff"} },

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=6, },
}
