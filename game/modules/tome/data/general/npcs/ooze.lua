-- last updated:  9:54 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_OOZE",
	type = "vermin", subtype = "oozes",
	display = "j", color=colors.WHITE,
	desc = "It's colorful and it's oozing.",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	stats = { str=10, dex=15, mag=3, con=10 },
	energy = { mod=0.7 },
	combat_armor = 1, combat_def = 1,

	resolvers.drops{chance=90, nb=1, {} },
	resolvers.drops{chance=60, nb=1, {type="money"} },

	resists = { [DamageType.LIGHT] = -50 },
	fear_immune = 1,
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "green ooze", color=colors.GREEN,
	desc = "It's green and it's oozing.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=5, damtype=DamageType.POISON },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "red ooze", color=colors.RED,
	desc = "It's red and it's oozing.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=5, damtype=DamageType.FIRE },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "blue ooze", color=colors.BLUE,
	desc = "It's blue and it's oozing.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=5, damtype=DamageType.COLD },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "white ooze", color=colors.WHITE,
	desc = "It's white and it's oozing.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=5 },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "yellow ooze", color=colors.YELLOW,
	desc = "It's yellow and it's oozing.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=5, damtype=DamageType.LIGHTNING },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "black ooze", color=colors.BLACK,
	desc = "It's black and it's oozing.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=5, damtype=DamageType.ACID },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "gelatinous cube", color=colors.BLACK,
	desc = [["It is a strange, vast gelatinous structure that assumes
	cubic proportions as it lines all four walls of the corridors it
	patrols. Through its transparent jelly structure you can see
	treasures it has engulfed, and a few corpses as well. "]],
	level_range = {12, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(50,100),
	combat = { dam=7, atk=15, apr=6, damtype=DamageType.ACID },
	drops = resolvers.drops{chance=90, nb=3, {} },
}