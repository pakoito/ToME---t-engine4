-- ToME - Tales of Maj'Eyal
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

load("/data/general/npcs/rodent.lua", rarity(4))
load("/data/general/npcs/vermin.lua", rarity(4))
load("/data/general/npcs/molds.lua", rarity(3))
load("/data/general/npcs/mummy.lua", rarity(0))
load("/data/general/npcs/skeleton.lua", rarity(3))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

-- The boss , no "rarity" field means it will not be randomly generated
newEntity{ define_as = "GREATER_MUMMY_LORD",
	allow_infinite_dungeon = true,
	type = "undead", subtype = "mummy", unique = true,
	name = "Greater Mummy Lord",
	display = "Z", color=colors.VIOLET,
	desc = [[The wrappings of this mummy radiate with so much power it feels like wind is blowing from them.]],
	level_range = {30, nil}, exp_worth = 2,
	max_life = 250, life_rating = 21, fixed_rating = true,
	max_stamina = 200,
	max_mana = 200,
	stats = { str=25, dex=10, cun=8, mag=35, wil=20, con=20 },
	rank = 4,
	size_category = 2,
	open_door = true,
	move_others=true,
	infravision = 20,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="longsword", defined="LONGSWORD_WINTERTIDE", random_art_replace={chance=75}, autoreq=true},
		{type="armor", subtype="shield", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="mummy", force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=4, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_SHIELD_PUMMEL]=5,
		[Talents.T_ASSAULT]=4,
		[Talents.T_OVERPOWER]=5,
		[Talents.T_BLINDING_SPEED]=4,
		[Talents.T_WEAPONS_MASTERY]=6,
		[Talents.T_WEAPON_COMBAT]=8,

		[Talents.T_FREEZE]=4,
		[Talents.T_ICE_STORM]=4,
		[Talents.T_INVISIBILITY]=4,

		[Talents.T_ROTTING_DISEASE]=5,
	},

	instakill_immune = 1,
	blind_immune = 1,
	see_invisible = 4,
	undead = 1,

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(3, "rune"),
	resolvers.inscriptions(1, {"manasurge rune", "manasurge rune"}),
}

-- Some mummy minions
newEntity{ base = "BASE_NPC_MUMMY",
	allow_infinite_dungeon = true,
	name = "ancient elven mummy", color=colors.ANTIQUE_WHITE,
	desc = [[An animated corpse in mummy wrappings.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(120,140),
	ai_state = { talent_in=4, },
	stats = { mag=25, wil=20, },
	infravision = 20,

	resolvers.equip{
		{type="weapon", subtype="greatsword", autoreq=true},
		{type="armor", subtype="mummy", autoreq=true},
	},
	resolvers.talents{
		[Talents.T_STUNNING_BLOW]=2,
		[Talents.T_CRUSH]=3,
		[Talents.T_MANATHRUST]=3,
	},
	resolvers.inscriptions(1, "rune"),
	resolvers.drops{chance=70, nb=1, {tome={money=1}} },
}

newEntity{ base = "BASE_NPC_MUMMY",
	allow_infinite_dungeon = true,
	name = "animated mummy wrappings", color=colors.SLATE, display='[', image="object/mummy_wrappings.png",
	desc = [[An animated set of mummy wrappings, without a corpse inside... It seems like it cannot move.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(20,40), life_rating=4,
	ai_state = { talent_in=2, },
	never_move = 1,
	infravision = 20,

	resolvers.equip{
		{type="armor", subtype="mummy", force_drop=true, autoreq=true},
	},
	autolevel = "caster",
	resolvers.talents{
		[Talents.T_MANATHRUST]=3,
		[Talents.T_FREEZE]=3,
		[Talents.T_LIGHTNING]=3,
		[Talents.T_STRIKE]=3,
	},
	resolvers.inscriptions(1, "rune"),
}

newEntity{ base = "BASE_NPC_MUMMY",
	allow_infinite_dungeon = true,
	name = "rotting mummy", color=colors.TAN,
	desc = [[A rotting animated corpse in mummy wrappings.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(60,80), life_rating=7,
	ai_state = { talent_in=4, },
	infravision = 20,

	resolvers.equip{
		{type="armor", subtype="mummy", autoreq=true},
	},
	autolevel = "ghoul",
	resolvers.talents{
		[Talents.T_WEAKNESS_DISEASE]=1,
		[Talents.T_GNAW]=3,
		[Talents.T_RETCH]=3,
		[Talents.T_BITE_POISON]=3,
	},
	combat = { dam=8, atk=10, apr=0, dammod={str=0.7} },
}

