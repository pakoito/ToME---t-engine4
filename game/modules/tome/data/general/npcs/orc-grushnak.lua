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
	define_as = "BASE_NPC_ORC_GRUSHNAK",
	type = "humanoid", subtype = "orc",
	display = "o", color=colors.UMBER,
	faction = "orc-pride", pride = "grushnak",

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
	resolvers.inscriptions(3, "infusion"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	stats = { str=20, dex=8, mag=6, con=16 },
	ingredient_on_death = "ORC_HEART",
}

newEntity{ base = "BASE_NPC_ORC_GRUSHNAK",
	name = "orc fighter", color=colors.KHAKI,
	desc = [[An orc clad in a massive armour, wielding a shield and a deadly axe.]],
	level_range = {30, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(110,120), life_rating = 14,
	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="massive", autoreq=true},
	},
	combat_armor = 0, combat_def = 5,

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=4, every=5, max=5},
		[Talents.T_WEAPON_COMBAT]={base=2, every=10, max=4},
		[Talents.T_WEAPONS_MASTERY]={base=2, every=10, max=4},
		[Talents.T_RUSH]={base=3, every=9, max=5},
		[Talents.T_SHIELD_PUMMEL]={base=3, every=7, max=6},
		[Talents.T_OVERPOWER]={base=3, every=7, max=6},
		[Talents.T_DISARM]={base=3, every=7, max=6},
	},
}

newEntity{ base = "BASE_NPC_ORC_GRUSHNAK",
	name = "orc elite fighter", color=colors.MOCCASIN,
	desc = [[An orc clad in a massive armour, wielding a shield and a deadly axe.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 3,
	rank = 3,
	max_life = resolvers.rngavg(170,180), life_rating = 14,
	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="massive", autoreq=true},
	},
	combat_armor = 0, combat_def = 5,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=5, every=5, max=8},
		[Talents.T_WEAPON_COMBAT]={base=4, every=10, max=6},
		[Talents.T_WEAPONS_MASTERY]={base=3, every=10, max=6},
		[Talents.T_RUSH]={base=3, every=7, max=6},
		[Talents.T_BATTLE_CALL]={base=3, every=7, max=6},
		[Talents.T_SHIELD_PUMMEL]={base=4, every=7, max=7},
		[Talents.T_OVERPOWER]={base=5, every=7, max=8},
		[Talents.T_ASSAULT]={base=3, every=7, max=6},
		[Talents.T_BATTLE_SHOUT]={base=3, every=7, max=6},
		[Talents.T_SHIELD_WALL]={base=5, every=6, max=8},
	},
}

newEntity{ base = "BASE_NPC_ORC_GRUSHNAK",
	name = "orc berserker", color=colors.SALMON,
	desc = [[An orc clad in a massive armour, wielding a huge axe.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(110,120), life_rating = 14,
	resolvers.equip{
		{type="weapon", subtype="battleaxe", autoreq=true},
		{type="armor", subtype="massive", autoreq=true},
	},
	combat_armor = 0, combat_def = 5,

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=4, every=5, max=5},
		[Talents.T_WEAPON_COMBAT]={base=2, every=10, max=4},
		[Talents.T_WEAPONS_MASTERY]={base=2, every=10, max=4},
		[Talents.T_RUSH]={base=3, every=7, max=6},
		[Talents.T_STUNNING_BLOW]={base=3, every=7, max=6},
		[Talents.T_BERSERKER]={base=3, every=7, max=6},
	},
}

newEntity{ base = "BASE_NPC_ORC_GRUSHNAK",
	name = "orc elite berserker", color=colors.YELLOW,
	desc = [[An orc clad in a massive armour, wielding a huge axe.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 3,
	rank = 3,
	max_life = resolvers.rngavg(170,180), life_rating = 14,
	resolvers.equip{
		{type="weapon", subtype="battleaxe", autoreq=true},
		{type="armor", subtype="massive", autoreq=true},
	},
	combat_armor = 0, combat_def = 5,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=5, every=5, max=8},
		[Talents.T_WEAPON_COMBAT]={base=4, every=10, max=6},
		[Talents.T_WEAPONS_MASTERY]={base=3, every=10, max=6},
		[Talents.T_RUSH]={base=3, every=7, max=6},
		[Talents.T_BATTLE_CALL]={base=3, every=7, max=6},
		[Talents.T_STUNNING_BLOW]={base=4, every=7, max=7},
		[Talents.T_JUGGERNAUT]={base=5, every=6, max=8},
		[Talents.T_SHATTERING_IMPACT]={base=5, every=6, max=8},
		[Talents.T_BATTLE_SHOUT]={base=3, every=7, max=6},
		[Talents.T_BERSERKER]={base=5, every=6, max=8},
	},
}
