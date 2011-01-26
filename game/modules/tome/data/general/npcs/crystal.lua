local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_CRYSTAL",
	type = "immovable", subtype = "crystal",
	display = "%", color=colors.WHITE,
	blood_color = colors.GREY,
	desc = "A shining crystal formation charged with magical energies.",
	body = { INVEN = 10 },
	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	resolvers.drops{chance=25, nb=1, {type="jewelry", ego_chance = 100}},
	max_life = resolvers.rngavg(12,34),
	stats = { str=1, dex=5, mag=20, con=1 },
	energy = { mod=0.5 },
	infravision = 20,
	combat_armor = 10, combat_def = 1,
	never_move = 1,
	blind_immune = 1,
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
	}
}


newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "red crystal", color=colors.RED,
	desc = "A formation of red crystal. It emits bright red, scorching light.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	resists = { [DamageType.FIRE] = 100, [DamageType.ICE] = -100 },
	resolvers.talents{
		[Talents.T_FLAME]=1,
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "white crystal", color=colors.WHITE,
	desc = "A formation of white crystal. It emits bright white, chilling light.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	resists = { [DamageType.ICE] = 100, [DamageType.FIRE] = -100 },
	resolvers.talents{
		[Talents.T_ICE_SHARDS]=1,
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "black crystal", color=colors.BLACK,
	desc = "A formation of black crystal. It absorbs all light around it.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 2,
	resists = { [DamageType.LIGHT] = 100 ,[DamageType.DARKNESS] = -100 },
	resolvers.talents{
		[Talents.T_SOUL_ROT]=1,
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "crimson crystal", color=colors.DARK_RED,
	desc = "A formation of crimson crystal. It emits a crimson light reminiscent of blood.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	resists = { [DamageType.LIGHT] = -100 },
	resolvers.talents{
		[Talents.T_BLOOD_GRASP]=1,
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "blue crystal", color=colors.BLUE,
	desc = "A formation of blue crystal. Its light shines like the ocean's waves.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 4,
	resists = { [DamageType.ICE] = -100 },
	resolvers.talents{
		[Talents.T_TIDAL_WAVE]=3,
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "multi-hued crystal", color=colors.VIOLET,
	shader = "quad_hue",
	desc = "A formation of multi-hued crystal. It shines with all the colors of the rainbow.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 4,
	resists = { [DamageType.LIGHT] = 100 },
	resolvers.talents{
		[Talents.T_ELEMENTAL_BOLT]=1,
	},
	talent_cd_reduction={
		[Talents.T_ELEMENTAL_BOLT]=2,
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "shimmering crystal", color=colors.GREEN,
	shader = "quad_hue",
	desc = "A formation of shimmering crystal. Orbs of light circle around it.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 5,
	resists = { [DamageType.LIGHT] = 100 },
	summon = {{name = "wisp", number=3, hasxp=false}},
	resolvers.talents{
		[Talents.T_SUMMON]=1,
	}
}
