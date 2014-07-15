-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SPIDER",
	type = "spiderkin", subtype = "spider",
	display = "S", color=colors.WHITE,
	desc = [[Arachnophobia...]],

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 70), 1, 0.9), atk=16, apr=9, damtype=DamageType.NATURE, dammod={dex=1.2} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 10,
	size_category = 2,
	rank = 1,

	autolevel = "spider",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=4, },
	global_speed_base = 1.2,
	stats = { str=15, dex=15, mag=8, con=10 },

	resolvers.inscriptions(2, "infusion"),

	resolvers.sustains_at_birth(),

	poison_immune = 0.9,
	resists = { [DamageType.NATURE] = 20, [DamageType.LIGHT] = -20 },
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "giant spider", color=colors.LIGHT_DARK,
	desc = [[A huge arachnid, it produces even bigger webs.]],
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 50,
	life_rating = 10,

	combat_armor = 5, combat_def = 5,

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=1, every=10, max=5},
		[Talents.T_LAY_WEB]={base=1, every=10, max=5},
	},
	ingredient_on_death = "SPIDER_SPINNERET",
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "spitting spider", color=colors.DARK_UMBER,
	desc = [[A huge arachnid, it sprays venom at its prey.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 60,
	life_rating = 10,

	combat_armor = 5, combat_def = 10,

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=3, every=10, max=6},
		[Talents.T_SPIT_POISON]={base=3, every=10, max=6},
		[Talents.T_LAY_WEB]={base=3, every=10, max=6},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "chitinous spider", color=colors.LIGHT_GREEN,
	desc = [[A huge arachnid with a massive exoskeleton.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 70,
	life_rating = 10,

	combat_armor = 10, combat_def = 14,

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=3, every=10, max=6},
		[Talents.T_LAY_WEB]={base=3, every=10, max=6},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "gaeramarth", color=colors.LIGHT_DARK,  -- dreadful fate
	desc = [[These cunning spiders terrorize those who enter the ever-growing borders of their lairs.  Those who encounter them rarely return.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 3,
	max_life = 120,
	life_rating = 13,

	combat_armor = 7, combat_def = 17,

	rank = 2,

	resolvers.tmasteries{ ["cunning/stealth"]=0.3},

	resolvers.talents{
		[Talents.T_RUSH]={base=4, every=6, max=7},
		[Talents.T_SPIDER_WEB]={base=4, every=6, max=7},
		[Talents.T_LAY_WEB]={base=4, every=6, max=7},
		[Talents.T_STEALTH]={base=4, every=6, max=7},
		[Talents.T_SHADOWSTRIKE]={base=4, every=6, max=7},
		[Talents.T_STUN]={base=2, every=6, max=5},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "ninurlhing", color=colors.DARK_GREEN,  -- water burn spider (acidic)
	desc = [[The air reeks with noxious fumes and the ground around it decays.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 3,
	max_life = 120,
	life_rating = 13,
	rank = 2,

	combat_armor = 7, combat_def = 17,

	resolvers.tmasteries{ ["wild-gift/slime"]=0.3, ["spell/water"]=0.3 },

	resolvers.talents{
		[Talents.T_RUSH]={base=5, every=6, max=8},
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_ACIDIC_SKIN]={base=5, every=6, max=8},
		[Talents.T_CORROSIVE_VAPOUR]={base=5, every=6, max=8},
		[Talents.T_CRAWL_ACID]={base=3, every=6, max=6},
		[Talents.T_STUN]={base=2, every=6, max=7},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "faerlhing", color=colors.PURPLE,  -- spirit spider (arcane)
	desc = [[This spider seems to command the flow of mana, which pulses freely through its body.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 4,
	max_life = 120,
	max_mana = 380,
	life_rating = 12,
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	combat_armor = 7, combat_def = 17,

	resolvers.tmasteries{ ["spell/phantasm"]=0.3, ["spell/water"]=0.3, ["spell/arcane"]=0.3 },

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_PHANTASMAL_SHIELD]={base=5, every=6, max=8},
		[Talents.T_PHASE_DOOR]={base=5, every=6, max=8},
		[Talents.T_MANATHRUST]={base=5, every=6, max=8},
		[Talents.T_MANAFLOW]={base=5, every=6, max=8},
		[Talents.T_DISRUPTION_SHIELD]={base=3, every=6, max=6},
		[Talents.T_ARCANE_POWER]={base=3, every=6, max=6},
	},
	ingredient_on_death = "FAERLHING_FANG",
}

-- the brethren of Ungoliant :D  tough and deadly, probably too tough, but meh <evil laughter>
newEntity{ base = "BASE_NPC_SPIDER",
	name = "ungolmor", color={0,0,0},  -- spider night, don't change the color
	desc = [[Largest of all the spiderkin, its folds of skin seem nearly impenetrable.]],
	level_range = {38, nil}, exp_worth = 1,
	rarity = 4,
	max_life = 120,
	life_rating = 16,
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	combat_armor = 75, combat_def = 12,  -- perhaps too impenetrable?  though at this level people should be doing over 100 damage each hit, so it could be more :D

	resolvers.tmasteries{ ["spell/aegis"]=0.9 },

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_REGENERATION]={base=5, every=6, max=8},
		[Talents.T_BITE_POISON]={base=5, every=6, max=8},
		[Talents.T_DARKNESS]={base=5, every=6, max=8},
		[Talents.T_RUSH]=5,
		[Talents.T_STUN]={base=3, every=6, max=6},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "losselhing", color=colors.LIGHT_BLUE,  -- snow star spider
	desc = [[The air seems to freeze solid around this frigid spider.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 4,
	max_life = 120,
	life_rating = 14,
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	combat_armor = 7, combat_def = 17,

	resolvers.tmasteries{ ["spell/enhancement"]=0.7, ["wild-gift/cold-drake"]=0.7, ["spell/water"]=0.7 },

	resolvers.talents{
		[Talents.T_RUSH]={base=5, every=6, max=8},
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_FREEZE]={base=5, every=6, max=8},
		[Talents.T_ICY_SKIN]={base=5, every=6, max=8},
		[Talents.T_TIDAL_WAVE]={base=3, every=6, max=6},
		[Talents.T_ICE_STORM]={base=2, every=6, max=6},
		[Talents.T_FROST_HANDS]={base=5, every=6, max=8},
	},

}

-- Fate Weavers; temporal spiders
-- Weavers spend most of their adult life outside of normal space and time but lay their eggs and grow to maturity in the normal bounds of spacetime.
-- Male Weavers are extremely rare on Eyal with the young being the most common and the females occasionally will be encountered when they're caring for their young or laying eggs
-- Ninandra, The Great Weaver is said to be the mother of all Weavers and binds the threads of fate that let the Weavers travel back and forth through the timestream

newEntity{ base = "BASE_NPC_SPIDER",
	name = "weaver young", color=colors.LIGHT_STEEL_BLUE,
	desc = [[A tiny arachnid that phases in and out of reality.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 2, -- older weavers are much rarer, as they age they become less connected to the normal timeline
	max_life = 60,
	life_rating = 10,

	size_category = 1,

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 70), 1, 0.9), atk=16, apr=9, damtype=DamageType.WASTING, dammod={dex=1.2} },

	combat_armor = 5, combat_def = 10,
	resists = { [DamageType.NATURE] = 20, [DamageType.LIGHT] = -20, [DamageType.TEMPORAL] = 20, },

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=1, every=10, max=5},
		[Talents.T_LAY_WEB]={base=1, every=10, max=5},
		[Talents.T_SPIN_FATE]={base=1, every=10, max=5},
		[Talents.T_SWAP]={base=1, every=10, max=5},
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "weaver patriarch", color=colors.STEEL_BLUE,
	desc = [[A large blue arachnid with white markings on its thorax.  It shifts and shimmers as though only partially connected to the timeline.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 12, -- the rarest of the weavers; they spend most of their time courting females in their home realm
	max_life = 120,
	life_rating = 13,
	rank = 2,

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 70), 1, 0.9), atk=16, apr=9, damtype=DamageType.WASTING, dammod={dex=1.2} },

	combat_armor = 7, combat_def = 17,
	resists = { [DamageType.NATURE] = 20, [DamageType.LIGHT] = -20, [DamageType.TEMPORAL] = 20, },

	talent_cd_reduction = {[Talents.T_RETHREAD]=-4},

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_SPIN_FATE]={base=5, every=6, max=8},
		[Talents.T_SWAP]={base=5, every=6, max=8},
		[Talents.T_RETHREAD]={base=5, every=6, max=8},
		[Talents.T_DISENTANGLE]={base=5, every=6, max=8},
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "weaver matriarch", female =1, color=colors.DARK_BLUE,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/spiderkin_spider_weaver_matriarch.png", display_h=2, display_y=-1}}},
	desc = [[A large dark blue arachnid with a shifting yellow and white pattern on its thorax.  It shifts and shimmers as though only partially connected to the timeline.]],
	level_range = {38, nil}, exp_worth = 1,
	rarity = 6, -- rarer then most spiderkin; only encountered in Maj'Eyal while laying eggs or caring for her young
	size_category = 3,
	max_life = 120,
	life_rating = 16,
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee", ai_state = { ai_move="move_complex", talent_in=2, },

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 70), 1, 0.9), atk=16, apr=9, damtype=DamageType.WASTING, dammod={dex=1.2} },

	combat_armor = 7, combat_def = 17,
	resists = { [DamageType.NATURE] = 20, [DamageType.LIGHT] = -20, [DamageType.TEMPORAL] = 20, },

	make_escort = {
		{type = "spiderkin", name="weaver young", number=2, no_subescort=true},
	},

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_SPIN_FATE]={base=5, every=6, max=8},
		[Talents.T_SWAP]={base=5, every=6, max=8},
		[Talents.T_RETHREAD]={base=5, every=6, max=8},
		[Talents.T_FADE_FROM_TIME]={base=5, every=6, max=8},
		[Talents.T_DISENTANGLE]={base=5, every=6, max=8},
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "Ninandra, the Great Weaver", female=1, unique = true,
	color = colors.VIOLET,
	rarity = 50,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/spiderkin_spider_ninandra_the_great_weaver.png", display_h=2, display_y=-1}}},
	desc = [[A huge blue and white spiderkin whose form shifts and shimmers in and out of reality.  She spins the threads of fate and binds the destiny of all within her web.]],
	level_range = {45, nil}, exp_worth = 4,
	max_life = 400, life_rating = 25, fixed_rating = true,
	rank = 3.5,
	size_category = 4,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="THREADS_FATE", random_art_replace={chance=65}}},
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee", ai_state = { ai_move="move_complex", talent_in=1, },

	combat = { dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 0.9), atk=16, apr=9, damtype=DamageType.WASTING, dammod={dex=1.2} },

	combat_armor = 7, combat_def = 17,
	resists = { [DamageType.NATURE] = 20, [DamageType.LIGHT] = -20, [DamageType.TEMPORAL] = 20, },
	combat_physresist = 50,
	combat_spellresist = 50,
	combat_mentalresist = 50,
	combat_spellpower = 50,
	see_invisible = 18,

	make_escort = {
		{type = "spiderkin", name="weaver patriarch", number=2, no_subescort=true},
	},

	summon = {
		{type = "spiderkin", subtype = "spider", name="weaver young", number=2, hasxp=false},
		{type = "spiderkin", subtype = "spider", name="weaver patriarch", number=1, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=7, every=6},
		[Talents.T_LAY_WEB]={base=7, every=6},

		-- Defensive Talents; should be hard to kill
		[Talents.T_DISPLACE_DAMAGE]={base=10, every=6}, -- Mwhaha
		[Talents.T_BODY_REVERSION]={base=7, every=6},
		[Talents.T_ENTROPIC_FIELD]={base=7, every=6},
		[Talents.T_FADE_FROM_TIME]={base=7, every=6},
		[Talents.T_SPIN_FATE]={base=7, every=6},

		[Talents.T_SWAP]={base=7, every=6},
		[Talents.T_DIMENSIONAL_STEP]={base=7, every=6},
		[Talents.T_RETHREAD]={base=7, every=6},
		[Talents.T_DISENTANGLE]={base=7, every=6},

		[Talents.T_SUMMON]=1,

		[Talents.T_LUCKY_DAY] = 1,
	},
}
