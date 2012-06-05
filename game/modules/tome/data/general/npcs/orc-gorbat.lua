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
	define_as = "BASE_NPC_ORC_GORBAT",
	type = "humanoid", subtype = "orc",
	display = "o", color=colors.GREEN,
	faction = "orc-pride", pride = "gorbat",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	lite = 1,

	life_rating = 15,
	rank = 2,
	size_category = 3,

	resolvers.racial(),

	open_door = true,
	resolvers.sustains_at_birth(),

	resolvers.inscriptions(2, "infusion"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	stats = { str=20, dex=8, mag=6, con=16 },
	ingredient_on_death = "ORC_HEART",
}

newEntity{ base = "BASE_NPC_ORC_GORBAT",
	name = "orc summoner", color=colors.YELLOW,
	desc = [[A fierce orc attuned to the wilds.]],
	level_range = {30, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	max_life = resolvers.rngavg(80,110),
	life_rating = 12,
	resolvers.equip{
		{type="weapon", subtype="sling", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,

	resolvers.inscriptions(1, "infusion"),

	autolevel = "summoner",
	resolvers.talents{
		[Talents.T_SLING_MASTERY]={base=3, every=5, max=10},
		[Talents.T_MINOTAUR]={base=4, every=6, max=7},
		[Talents.T_RITCH_FLAMESPITTER]={base=4, every=5, max=7},
		[Talents.T_SPIDER]={base=3, every=5, max=6},
		[Talents.T_FRANTIC_SUMMONING]={base=1, every=5, max=5},
		[Talents.T_SHOOT]=1,
	},
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_ORC_GORBAT",
	name = "orc grand summoner", color=colors.SALMON,
	desc = [[A fierce orc attuned to the wilds.]],
	level_range = {30, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	max_life = resolvers.rngavg(100,110),
	life_rating = 13,
	resolvers.equip{
		{type="weapon", subtype="sling", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,

	autolevel = "summoner",
	ai = "tactical",
	resolvers.inscriptions(2, "infusion"),

	resolvers.talents{
		[Talents.T_SLING_MASTERY]={base=2, every=10, max=5},
		[Talents.T_MINOTAUR]={base=5, every=6, max=9},
		[Talents.T_STONE_GOLEM]={base=5, every=6, max=9},
		[Talents.T_RITCH_FLAMESPITTER]={base=4, every=5, max=9},
		[Talents.T_SPIDER]={base=5, every=5, max=8},
		[Talents.T_RESOLVE]={base=4, every=5, max=6},
		[Talents.T_NATURE_TOUCH]={base=3, every=5, max=8},
		[Talents.T_FRANTIC_SUMMONING]={base=2, every=5, max=7},
		[Talents.T_NATURE_S_BALANCE]=5,
		[Talents.T_SHOOT]=1,
	},
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_ORC_GORBAT",
	name = "orc master wyrmic", color=colors.LIGHT_STEEL_BLUE,
	desc = [[A fierce soldier-orc highly trained in the discipline of dragons.]],
	level_range = {30, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	max_life = resolvers.rngavg(120,150),
	life_rating = 15,
	resolvers.equip{
		{type="weapon", subtype="battleaxe", autoreq=true},
		{type="armor", subtype="light", autoreq=true},
	},
	combat_armor = 2, combat_def = 3,

	autolevel = "warriorwill",
	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(1, "infusion"),

	resolvers.talents{
		[Talents.T_WEAPONS_MASTERY]={base=2, every=10, max=7},
		[Talents.T_ICE_CLAW]={base=4, every=6, max=8},
		[Talents.T_ICY_SKIN]={base=4, every=5, max=8},
		[Talents.T_ICE_BREATH]={base=4, every=5, max=9},
		[Talents.T_FIRE_BREATH]={base=4, every=5, max=9},
		[Talents.T_SAND_BREATH]={base=4, every=5, max=9},
		[Talents.T_TORNADO]={base=4, every=5, max=9},
		[Talents.T_LIGHTNING_SPEED]={base=4, every=5, max=9},
		[Talents.T_BELLOWING_ROAR]={base=4, every=5, max=9},
	},
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_ORC_GORBAT",
	name = "orc mage-hunter", color=colors.HONEYDEW,
	desc = [[An orc clad in massive armour, magic seems to die down all around him.]],
	level_range = {30, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	max_life = resolvers.rngavg(120,150),
	life_rating = 15,
	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="massive", autoreq=true},
	},
	combat_armor = 2, combat_def = 3,

	autolevel = "warriorwill",
	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(2, "infusion"),

	resolvers.talents{
		[Talents.T_WEAPONS_MASTERY]={base=2, every=10, max=7},
		[Talents.T_WEAPON_COMBAT]={base=2, every=10, max=7},
		[Talents.T_ARMOUR_TRAINING]={base=5, every=5, max=14},
		[Talents.T_RESOLVE]={base=4, every=5, max=9},
		[Talents.T_ANTIMAGIC_SHIELD]={base=4, every=5, max=9},
		[Talents.T_AURA_OF_SILENCE]={base=4, every=5, max=9},
		[Talents.T_MANA_CLASH]={base=4, every=5, max=9},
	},
	resolvers.racial(),
}
