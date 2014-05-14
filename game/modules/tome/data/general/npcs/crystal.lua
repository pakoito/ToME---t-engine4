local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_CRYSTAL",
	type = "immovable", subtype = "crystal", image = "npc/crystal_npc.png",
	display = "%", color=colors.WHITE,
	blood_color = colors.GREY,
	desc = "A shining crystal formation charged with magical energies.",
	body = { INVEN = 10 },
	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },

	resolvers.drops{chance=15, nb=1, {type="jewelry"}},

	max_life = resolvers.rngavg(12,34),
	stats = { str=1, dex=5, mag=20, con=1 },
	global_speed_base = 0.7,
	infravision = 10,
	combat_def = 1,
	never_move = 1,
	slow_projectiles_outgoing = 50,
	blind_immune = 1,
	cut_immune = 1,
	fear_immune = 1,
	rank = 2,
	size_category = 2,
	poison_immune = 1,
	disease_immune = 1,
	no_breath = 1,
	confusion_immune = 1,
	disease_immune = 1,
	poison_immune = 1,
	see_invisible = 25,
	resolvers.talents{
		[Talents.T_PHASE_DOOR]=1,
	},

	lite = 2,
	not_power_source = {nature=true, technique=true},
}

newEntity{ name = "wisp",
	type = "elemental", subtype = "light",
	display = "*", color=colors.YELLOW, tint=colors.YELLOW,
	desc = [[A floating orb of magical energy. It shines with a radiant light. They explode upon contact.]],
	combat = { dam=10, atk=5, apr=10, physspeed=1 },
	blood_color = colors.YELLOW,
	level_range = {1, nil},
	exp_worth = 1,
	max_life = 10,
	body = { INVEN = 1, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	no_drops = true, open_door = false,
	infravision = 10,
	rarity = false,
	rarity_summoned_crystal = 1,
	lite = 4,
	life_rating = 1, rank = 1, size_category = 1,
	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move = "move_astar", talent_in = 1 },
	global_speed_base = 1,
	stats = { str = 9, dex = 20, mag = 20 },
	resolvers.talents{
		[Talents.T_EXPLODE] = 3,
	},
	no_breath = 1,
	blind_immune = 1,
	fear_immune = 1,
	rank = 2,
	size_category = 1,
	poison_immune = 1,
	disease_immune = 1,
	poison_immune = 1,
	stun_immune = 1,
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "red crystal", color=colors.RED, tint=colors.RED, image = "npc/crystal_red.png",
	desc = "A formation of red crystal. It emits bright red, scorching light.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	resists = { [DamageType.FIRE] = 100, [DamageType.COLD] = -100 },
	resolvers.talents{
		[Talents.T_FLAME_BOLT]={base=1, every=1, max=20},
	},
	ingredient_on_death = "RED_CRYSTAL_SHARD",
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "white crystal", color=colors.WHITE, tint=colors.WHITE,
	desc = "A formation of white crystal. It emits bright white, chilling light.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	resists = { [DamageType.COLD] = 100, [DamageType.FIRE] = -100 },
	resolvers.talents{
		[Talents.T_ICE_BOLT]={base=1, every=1, max=20},
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "black crystal", color=colors.BLACK, tint=colors.BLACK, image = "npc/crystal_black.png",
	desc = "A formation of black crystal. It absorbs all light around it.",
	level_range = {3, nil}, exp_worth = 1,
	rarity = 2,
	resists = { [DamageType.LIGHT] = 100 ,[DamageType.DARKNESS] = -100 },
	resolvers.talents{
		[Talents.T_BLIGHT_BOLT]={base=1, every=1, max=20},
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "crimson crystal", color=colors.DARK_RED, tint=colors.DARK_RED, image = "npc/crystal_darkred.png",
	desc = "A formation of crimson crystal. It emits a crimson light reminiscent of blood.",
	level_range = {3, nil}, exp_worth = 1,
	rarity = 3,
	resists = { [DamageType.LIGHT] = -100 },
	resolvers.talents{
		[Talents.T_BLOOD_GRASP]={base=1, every=7, max=5},
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "blue crystal", color=colors.BLUE, tint=colors.BLUE, image = "npc/crystal_blue.png",
	desc = "A formation of blue crystal. Its light shines like the ocean's waves.",
	level_range = {3, nil}, exp_worth = 1,
	rarity = 4,
	resists = { [DamageType.COLD] = -100 },
	resolvers.talents{
		[Talents.T_TIDAL_WAVE]={base=3, every=9, max=5},
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "multi-hued crystal", color=colors.VIOLET, tint=colors.VIOLET, image = "npc/crystal_violet.png",
	shader = "quad_hue",
	desc = "A formation of multi-hued crystal. It shines with all the colors of the rainbow.",
	level_range = {10, nil}, exp_worth = 1,
	rarity = 4,
	resists = { [DamageType.LIGHT] = 100 },
	resolvers.talents{
		[Talents.T_ELEMENTAL_BOLT]={base=1, every=7, max=5},
	},
	talent_cd_reduction={
		[Talents.T_ELEMENTAL_BOLT]=2,
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "shimmering crystal", color=colors.GREEN, tint=colors.GREEN,
	shader = "quad_hue",
	desc = "A formation of shimmering crystal. Orbs of light circle around it.",
	level_range = {10, nil}, exp_worth = 1,
	rarity = 5,
	resists = { [DamageType.LIGHT] = 100 },
	summon = {{name = "wisp", number=3, hasxp=false, special_rarity="rarity_summoned_crystal"}},
	resolvers.talents{
		[Talents.T_SUMMON]=1,
	}
}
