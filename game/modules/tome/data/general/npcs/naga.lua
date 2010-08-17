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
	define_as = "BASE_NPC_NAGA",
	type = "humanoid", subtype = "naga",
	display = "n", color=colors.AQUAMARINE,

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 20,
	can_breath={water=1},

	life_rating = 11,
	rank = 2,
	size_category = 3,

	open_door = true,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	energy = { mod=1.2 },
	stats = { str=15, dex=15, mag=15, con=10 },
}

newEntity{ base = "BASE_NPC_NAGA",
	name = "naga myrmidon", color=colors.DARK_UMBER,
	desc = [[A naga warrior, wielding a menacing trident.
Myrmidons are the most devoted warriors, following the orders of Maglor whatever they may be.]],
	level_range = {30, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(120,150), life_rating = 16,
	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, special_rarity="trident_rarity"},
	},
	combat_armor = 20, combat_def = 10,
	resolvers.talents{
		[Talents.T_SPIT_POISON]=5,
		[Talents.T_SUNDER_ARMOUR]=4,
		[Talents.T_STUNNING_BLOW]=3,
		[Talents.T_RUSH]=8,
		[Talents.T_WEAPON_COMBAT]=6,
		[Talents.T_EXOTIC_WEAPONS_MASTERY]=6,
	},
}

newEntity{ base = "BASE_NPC_NAGA",
	name = "naga tide huntress", color=colors.RED,
	desc = [[A naga hunter, wielding a long bow.
Tide huntress wield both magic and hunting skills, making them terrible foes.]],
	level_range = {34, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	female = true,
	max_life = resolvers.rngavg(110,130), life_rating = 14,
	resolvers.equip{
		{type="weapon", subtype="longbow", autoreq=true},
		{type="ammo", subtype="arrow", autoreq=true},
	},
	combat_armor = 10, combat_def = 10,
	autolevel = "warriormage",
	resolvers.talents{
		[Talents.T_SPIT_POISON]=5,
		[Talents.T_WATER_JET]=6,
		[Talents.T_WATER_BOLT]=7,
		[Talents.T_SHOOT]=1,
		[Talents.T_WEAPON_COMBAT]=6,
		[Talents.T_BOW_MASTERY]=6,
	},
}

newEntity{ base = "BASE_NPC_NAGA",
	name = "naga psyren", color=colors.YELLOW,
	desc = [[A naga psyren, she looks at you with great intensity.
Psyrens are dangerous naga that can directly assault your mind.]],
	level_range = {36, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	female = true,
	max_life = resolvers.rngavg(100,110), life_rating = 11,
	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, special_rarity="trident_rarity"},
	},
	combat_armor = 5, combat_def = 10,
	autolevel = "wildcaster",
	resolvers.talents{
		[Talents.T_MIND_DISRUPTION]=4,
		[Talents.T_MIND_SEAR]=5,
		[Talents.T_SILENCE]=4,
		[Talents.T_TELEKINETIC_BLAST]=4,
	},
}
