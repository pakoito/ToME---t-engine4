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

-- last updated: 9:25 AM 2/5/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_ELVEN_WARRIOR",
	type = "humanoid", subtype = "shalore",
	display = "p", color=colors.UMBER,
	faction = "rhalore",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	lite = 1,

	life_rating = 15,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),
	resolvers.talents{ [Talents.T_ARMOUR_TRAINING]=5, [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	stats = { str=20, dex=8, mag=6, con=16 },
	power_source = {technique=true},
}

newEntity{ base = "BASE_NPC_ELVEN_WARRIOR",
	name = "elven guard", color=colors.LIGHT_UMBER,
	desc = [[An elven guard.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{ [Talents.T_SHIELD_PUMMEL]={base=1, every=10, max=5}, },
}

newEntity{ base = "BASE_NPC_ELVEN_WARRIOR",
	name = "mean looking elven guard", color=colors.UMBER,
	desc = [[An elven guard, scarred and sullen.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(100,110), life_rating = 11,
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{ [Talents.T_BLEEDING_EDGE]={base=1, every=10, max=5}, },
}

newEntity{ base = "BASE_NPC_ELVEN_WARRIOR",
	name = "elven warrior", color=colors.LIGHT_UMBER,
	desc = [[An elven warrior, clad in heavy armour.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(100,110),
	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="heavy", autoreq=true},
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{ [Talents.T_SHIELD_PUMMEL]={base=2, every=10, max=6}, },
	resolvers.inscriptions(1, "rune"),
}

newEntity{ base = "BASE_NPC_ELVEN_WARRIOR",
	name = "elven elite warrior", color=colors.UMBER,
	desc = [[An elven warrior, clad in heavy armour.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",
	max_life = resolvers.rngavg(100,110),
	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="heavy", autoreq=true},
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{
		[Talents.T_SHIELD_PUMMEL]={base=2, every=10, max=7},
		[Talents.T_ASSAULT]={base=3, every=7, max=7},
	},
	resolvers.inscriptions(1, "rune"),
}
