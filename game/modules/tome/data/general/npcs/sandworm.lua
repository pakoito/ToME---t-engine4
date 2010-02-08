local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SANDWORM",
	type = "vermin", subtype = "sandworm",
	display = "w", color=colors.YELLOW,
	level_range = {12, 18},
	body = { INVEN = 10 },

	max_life = 40, life_rating = 5,
	max_stamina = 85,
	max_mana = 85,
	resists = { [DamageType.FIRE] = 30, [DamageType.COLD] = -30 },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	stats = { str=15, dex=7, mag=3, con=3 },
	combat_armor = 1, combat_def = 1,
}

newEntity{ base = "BASE_NPC_SANDWORM",
	name = "sandworm",
	desc = [[A huge worm coloured as the sand it inhabits. It seems quite unhappy about you being in its lair..]],
	rarity = 4,
}

newEntity{ base = "BASE_NPC_SANDWORM",
	name = "sandworm destroyer",
	desc = [[A huge worm coloured as the sand it inhabits. This particular sandworm seems to have been bred for one purpose only, the eradication of everything that is non-sandworm, such as ... you.]],
	rarity = 6,

	talents = resolvers.talents{
		[Talents.T_STAMINA_POOL]=1,
		[Talents.T_STUN]=2,
		[Talents.T_KNOCKBACK]=2,
	},
}

newEntity{ base = "BASE_NPC_SANDWORM",
	name = "sand-drake",
	desc = [[This unholy creature looks like a wingless dragon in shape but ressembles a sandworm in color.]],
	rarity = 8,

	talents = resolvers.talents{
		[Talents.T_STAMINA_POOL]=1,
		[Talents.T_SAND_BREATH]=3,
		[Talents.T_KNOCKBACK]=2,
	},
}
