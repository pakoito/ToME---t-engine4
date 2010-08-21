-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
	faction = "orc-pride",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 20,
	lite = 2,

	life_rating = 15,
	rank = 2,
	size_category = 3,

	open_door = true,
	resolvers.sustains_at_birth(),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	energy = { mod=1 },
	stats = { str=20, dex=8, mag=6, con=16 },
}

newEntity{ base = "BASE_NPC_ORC_GRUSHNAK",
	name = "uruk-hai figther", color=colors.UMBER,
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
		[Talents.T_MASSIVE_ARMOUR_TRAINING]=1,
		[Talents.T_WEAPON_COMBAT]=4,
		[Talents.T_AXE_MASTERY]=4,
		[Talents.T_RUSH]=3,
		[Talents.T_SHIELD_PUMMEL]=3,
		[Talents.T_OVERPOWER]=3,
		[Talents.T_DISARM]=3,
	},
}

newEntity{ base = "BASE_NPC_ORC_GRUSHNAK",
	name = "uruk-hai elite figther", color=colors.UMBER,
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

	resolvers.talents{
		[Talents.T_MASSIVE_ARMOUR_TRAINING]=5,
		[Talents.T_WEAPON_COMBAT]=8,
		[Talents.T_AXE_MASTERY]=6,
		[Talents.T_RUSH]=3,
		[Talents.T_BATTLE_CALL]=3,
		[Talents.T_SHIELD_PUMMEL]=4,
		[Talents.T_OVERPOWER]=5,
		[Talents.T_ASSAULT]=3,
		[Talents.T_BATTLE_SHOUT]=3,
		[Talents.T_SHIELD_WALL]=5,
	},
}

newEntity{ base = "BASE_NPC_ORC_GRUSHNAK",
	name = "uruk-hai berserker", color=colors.UMBER,
	desc = [[An orc clad in a massive armour, wielding a huge axe.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(110,120), life_rating = 14,
	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="massive", autoreq=true},
	},
	combat_armor = 0, combat_def = 5,

	resolvers.talents{
		[Talents.T_MASSIVE_ARMOUR_TRAINING]=1,
		[Talents.T_WEAPON_COMBAT]=4,
		[Talents.T_AXE_MASTERY]=4,
		[Talents.T_RUSH]=3,
		[Talents.T_STUNNING_BLOW]=3,
		[Talents.T_BERSERKER]=3,
	},
}

newEntity{ base = "BASE_NPC_ORC_GRUSHNAK",
	name = "uruk-hai elite berserker", color=colors.UMBER,
	desc = [[An orc clad in a massive armour, wielding a huge axe.]],
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

	resolvers.talents{
		[Talents.T_MASSIVE_ARMOUR_TRAINING]=5,
		[Talents.T_WEAPON_COMBAT]=8,
		[Talents.T_AXE_MASTERY]=6,
		[Talents.T_RUSH]=3,
		[Talents.T_BATTLE_CALL]=3,
		[Talents.T_STUNNING_BLOW]=4,
		[Talents.T_JUGGERNAUT]=5,
		[Talents.T_SHATTERING_IMPACT]=5,
		[Talents.T_BATTLE_SHOUT]=3,
		[Talents.T_BERSERKER]=5,
	},
}
