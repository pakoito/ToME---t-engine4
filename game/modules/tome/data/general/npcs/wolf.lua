newEntity{
	define_as = "BASE_NPC_WOLF",
	type = "animal", subtype = "wolf",
	display = "C", color=colors.WHITE,
	body = { INVEN = 10 },

	max_stamina = 150,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	energy = { mod=1.2 },
	stats = { str=10, dex=17, mag=3, con=7 },
	combat_armor = 1, combat_def = 1,
}

newEntity{ base = "BASE_NPC_WOLF",
	name = "wolf", color=colors.UMBER,
	desc = [[Lean, mean and shaggy, it stares at you with hungry eyes.]],
	level_range = {1, 50}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(40,70),
	combat_armor = 1, combat_def = 3,
	combat = { dam=5, atk=15, apr=10 },
}

newEntity{ base = "BASE_NPC_WOLF",
	name = "great wolf", color=colors.UMBER,
	desc = [[Larger than a normal wolf, it prowls and snaps at you.]],
	level_range = {3, 50}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(60,90),
	combat_armor =2, combat_def = 4,
	combat = { dam=7, atk=15, apr=10 },
}

newEntity{ base = "BASE_NPC_WOLF",
	name = "dire wolf", color=colors.DARK_UMBER,
	desc = [[Easily as big as a horse, this wolf menaces you with its claws and fangs.]],
	level_range = {4, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(80,110),
	combat_armor = 3, combat_def = 5,
	combat = { dam=13, atk=15, apr=10 },
}

newEntity{ base = "BASE_NPC_WOLF",
	name = "white wolf", color=colors.WHITE,
	desc = [[A large and muscled wolf from the northern wastes. Its breath is cold and icy and its fur coated in frost.]],
	level_range = {4, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(70,100),
	combat_armor = 3, combat_def = 4,
	combat = { dam=8, atk=15, apr=10 },

	resists = { [DamageType.FIRE] = -50, [DamageType.COLD] = 100 },
}

newEntity{ base = "BASE_NPC_WOLF",
	name = "warg", color=colors.BLACK,
	desc = [[It is a large wolf with eyes full of cunning.]],
	level_range = {5, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(60,100),
	combat_armor = 5, combat_def = 7,
	combat = { dam=15, atk=17, apr=10 },
}
