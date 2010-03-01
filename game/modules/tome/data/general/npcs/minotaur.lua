-- last updated: 11:56 AM 2/5/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_MINOTAUR",
	type = "giant", subtype = "minotaur",
	display = "H", color=colors.WHITE,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=40, nb=1, {{type="money"}} },

	max_stamina = 100,
	life_rating = 13,
	max_life = resolvers.rngavg(100,120),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=5, },
	energy = { mod=1.2 },
	stats = { str=15, dex=12, mag=6, cun=12, con=15 },

	tmasteries = resolvers.tmasteries{ ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3, ["technique/combat-training"]=0.3, },
}

newEntity{ base = "BASE_NPC_MINOTAUR",
	name = "minotaur", color=colors.UMBER,
	desc = [[It is a cross between a human and a bull.]],
	equipment = resolvers.equip{ {type="weapon", subtype="greataxe"}, },
	level_range = {10, 50}, exp_worth = 1,
	rarity = 9,
	combat_armor = 13, combat_def = 8,
	talents = resolvers.talents{ [Talents.T_WARSHOUT]=3, [Talents.T_STUNNING_BLOW]=3, [Talents.T_SUNDER_ARMOUR]=2, [Talents.T_SUNDER_ARMS]=2, },
}

newEntity{ base = "BASE_NPC_MINOTAUR",
	name = "maulotaur", color=colors.SLATE,
	desc = [[It is a belligerent minotaur with a destructive magical arsenal, armed with a hammer.]],
	level_range = {20, 50}, exp_worth = 1,
	rarity = 15,
	combat_armor = 15, combat_def = 7,
	equipment = resolvers.equip{ {type="weapon", subtype="maul"} },

	autolevel = "caster",
	resists = { [DamageType.FIRE] = 100 },
	max_mana = 100,
	talents = resolvers.talents{ [Talents.T_MANA_POOL]=1, [Talents.T_FLAME]=3, [Talents.T_FIREFLASH]=2 },
}
