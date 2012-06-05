-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	define_as = "BASE_NPC_ORC",
	type = "humanoid", subtype = "orc",
	display = "o", color=colors.UMBER,
	faction = "orc-pride",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	lite = 2,

	life_rating = 11,
	rank = 2,
	size_category = 3,

	open_door = true,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	stats = { str=20, dex=8, mag=6, con=16 },
	resolvers.talents{ [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, },
	ingredient_on_death = "ORC_HEART",
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "HILL_ORC_WARRIOR",
	name = "orc warrior", color=colors.LIGHT_UMBER,
	desc = [[He is a hardy, well-weathered survivor.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	resolvers.inscriptions(1, "infusion"),
	combat_armor = 2, combat_def = 0,
	resolvers.talents{
		[Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5},
		[Talents.T_SHIELD_PUMMEL]={base=1, every=6, max=5},
	},
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "HILL_ORC_ARCHER",
	name = "orc archer", color=colors.UMBER,
	desc = [[He is a hardy, well-weathered survivor.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 5, combat_def = 1,
	resolvers.talents{
		[Talents.T_BOW_MASTERY]={base=1, every=10, max=5},
		[Talents.T_SHOOT]=1,
	},
	ai_state = { talent_in=1, },

	autolevel = "archer",
	resolvers.inscriptions(1, "infusion"),
	resolvers.equip{
		{type="weapon", subtype="longbow", autoreq=true},
		{type="ammo", subtype="arrow", autoreq=true},
	},
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_ORC", define_as = "ORC",
	name = "orc soldier", color=colors.DARK_RED,
	desc = [[A fierce soldier-orc.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(120,140),
	life_rating = 11,
	resolvers.equip{
		{type="weapon", subtype="battleaxe", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.inscriptions(1, "infusion"),
	resolvers.talents{
		[Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5},
		[Talents.T_SUNDER_ARMOUR]={base=1, every=7, max=5},
		[Talents.T_CRUSH]={base=1, every=4, max=5},
	},
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_ORC", define_as = "ORC_FIRE_WYRMIC",
	name = "fiery orc wyrmic", color=colors.RED,
	desc = [[A fierce soldier-orc trained in the discipline of dragons.]],
	level_range = {11, nil}, exp_worth = 1,
	rarity = 6,
	rank = 3,
	max_life = resolvers.rngavg(100,110),
	life_rating = 10,
	resolvers.equip{
		{type="weapon", subtype="battleaxe", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(1, "infusion"),
	make_escort = {
		{type="humanoid", subtype="orc", name="orc soldier", number=resolvers.mbonus(3, 2)},
	},

	resolvers.talents{
		[Talents.T_WEAPONS_MASTERY]={base=2, every=10, max=5},
		[Talents.T_BELLOWING_ROAR]={base=2, every=6, max=5},
		[Talents.T_WING_BUFFET]={base=2, every=5, max=5},
		[Talents.T_FIRE_BREATH]={base=2, every=5, max=5},
	},
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_ORC",
	name = "icy orc wyrmic", color=colors.BLUE, define_as = "ORC_ICE_WYRMIC",
	desc = [[A fierce soldier-orc trained in the discipline of dragons.]],
	level_range = {11, nil}, exp_worth = 1,
	rarity = 6,
	rank = 3,
	max_life = resolvers.rngavg(100,110),
	life_rating = 10,
	resolvers.equip{
		{type="weapon", subtype="battleaxe", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(1, "infusion"),
	make_escort = {
		{type="humanoid", subtype="orc", name="orc soldier", number=resolvers.mbonus(3, 2)},
	},

	resolvers.talents{
		[Talents.T_WEAPONS_MASTERY]={base=2, every=10, max=5},
		[Talents.T_ICE_CLAW]={base=2, every=6, max=5},
		[Talents.T_ICY_SKIN]={base=2, every=5, max=5},
		[Talents.T_ICE_BREATH]={base=2, every=5, max=5},
	},
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_ORC",
	name = "orc assassin", color_r=0, color_g=0, color_b=resolvers.rngrange(175, 195),
	desc = [[An orc trained in the secret ways of assassination, stealthy and deadly.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 3,
	infravision = 10,
	combat_armor = 2, combat_def = 12,
	resolvers.equip{
		{type="weapon", subtype="dagger", autoreq=true},
		{type="weapon", subtype="dagger", autoreq=true},
		{type="armor", subtype="light", autoreq=true}
	},
	resolvers.talents{
		[Talents.T_KNIFE_MASTERY]={base=2, every=10, max=5},
		[Talents.T_STEALTH]=5,
		[Talents.T_LETHALITY]=4,
		[Talents.T_SHADOWSTRIKE]={base=3, every=6, max=5},
		[Talents.T_VILE_POISONS]={base=2, every=8, max=5},
		[Talents.T_VENOMOUS_STRIKE]={last=15, base=0, every=6, max=5},
	},
	max_life = resolvers.rngavg(80,100),
	resolvers.inscriptions(1, "infusion"),

	resolvers.sustains_at_birth(),
	autolevel = "rogue",
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_ORC",
	name = "orc master assassin", color_r=0, color_g=70, color_b=resolvers.rngrange(175, 195),
	desc = [[An orc trained in the secret ways of assassination, stealthy and deadly.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	infravision = 10,
	combat_armor = 2, combat_def = 18,
	resolvers.equip{
		{type="weapon", subtype="dagger", ego_chance=20, autoreq=true},
		{type="weapon", subtype="dagger", ego_chance=20, autoreq=true},
		{type="armor", subtype="light", autoreq=true}
	},

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(1, "infusion"),
	resolvers.talents{
		[Talents.T_KNIFE_MASTERY]={base=2, every=10, max=5},
		[Talents.T_STEALTH]=5,
		[Talents.T_LETHALITY]=4,
		[Talents.T_SHADOWSTRIKE]=5,
		[Talents.T_HIDE_IN_PLAIN_SIGHT]={base=2, every=6, max=5},
		[Talents.T_VILE_POISONS]={base=3, every=8, max=5},
		[Talents.T_VENOMOUS_STRIKE]={base=1, every=6, max=5},
	},
	max_life = resolvers.rngavg(80,100),

	resolvers.sustains_at_birth(),
	autolevel = "rogue",
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_ORC",
	name = "orc grand master assassin", color_r=0, color_g=70, color_b=resolvers.rngrange(175, 195),
	desc = [[An orc trained in the secret ways of assassination, stealthy and deadly.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	infravision = 10,
	combat_armor = 2, combat_def = 18,
	resolvers.equip{
		{type="weapon", subtype="dagger", ego_chance=20, autoreq=true},
		{type="weapon", subtype="dagger", ego_chance=20, autoreq=true},
		{type="armor", subtype="light", autoreq=true}
	},

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(3, "infusion"),
	resolvers.talents{
		[Talents.T_KNIFE_MASTERY]={base=2, every=10, max=5},
		[Talents.T_STEALTH]=5,
		[Talents.T_LETHALITY]={base=4, every=5, max=6},
		[Talents.T_DEADLY_STRIKES]={base=3, every=5, max=6},
		[Talents.T_SHADOWSTRIKE]=5,
		[Talents.T_HIDE_IN_PLAIN_SIGHT]={base=3, every=5, max=5},
		[Talents.T_UNSEEN_ACTIONS]={base=3, every=5, max=5},
		[Talents.T_VILE_POISONS]={base=3, every=8, max=5},
		[Talents.T_VENOMOUS_STRIKE]={base=2, every=6, max=5},
		[Talents.T_EMPOWER_POISONS]={base=3, every=7, max=5},
	},
	max_life = resolvers.rngavg(80,100),

	resolvers.sustains_at_birth(),
	autolevel = "rogue",
	resolvers.racial(),
}

-- Unique orcs
newEntity{ base = "BASE_NPC_ORC",
	name = "Kra'Tor the Gluttonous", unique = true,
	color=colors.DARK_KHAKI,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_orc_kra_tor_the_gluttonous.png", display_h=2, display_y=-1}}},
	desc = [[A morbidly obese orc with greasy pockmarked skin and oily long black hair.  He's clad in plate mail and carries a huge granite battleaxe that's nearly as large as he is.]],
	level_range = {38, nil}, exp_worth = 2,
	rarity = 50,
	rank = 3.5,
	max_life = resolvers.rngavg(600, 800),
	life_rating = 22,
	move_others=true,

	resolvers.equip{
		{type="weapon", subtype="battleaxe", defined="GAPING_MAW", random_art_replace={chance=75}, autoreq=true},
		{type="armor", subtype="massive", tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=2, {tome_drops="boss"} },

	combat_armor = 2, combat_def = 0,

	blind_immune = 0.5,
	confuse_immune = 0.5,
	stun_immune = 0.7,
	knockback_immune = 1,

	autolevel = "wyrmic",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(4, {"movement infusion", "healing infusion", "regeneration infusion", "wild infusion"}),

	resists = { all=25},

	resolvers.talents{
		[Talents.T_ICE_CLAW]={base=4, every=4, max=8},
		[Talents.T_ICY_SKIN]={base=5, every=4, max=9},
		[Talents.T_SAND_BREATH]={base=5, every=4, max=9},

		[Talents.T_RESOLVE]=5,
		[Talents.T_AURA_OF_SILENCE]=5,
		[Talents.T_MANA_CLASH]={base=5, every=5, max=8},

		[Talents.T_WARSHOUT]={base=4, every=4, max=8},
		[Talents.T_DEATH_DANCE]={base=3, every=4, max=7},
		[Talents.T_BERSERKER]={base=5, every=4, max=10},
		[Talents.T_BATTLE_CALL]={base=5, every=4, max=8},
		[Talents.T_CRUSH]={base=3, every=4, max=8},

		[Talents.T_WEAPON_COMBAT]={base=3, every=8, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=3, every=8, max=5},

		[Talents.T_ARMOUR_TRAINING]={base=5, every=4, max=12},
	},
	resolvers.sustains_at_birth(),
}
