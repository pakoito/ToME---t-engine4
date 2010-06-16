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

load("/data/general/npcs/rodent.lua")
load("/data/general/npcs/vermin.lua")
load("/data/general/npcs/molds.lua")
load("/data/general/npcs/mummy.lua")
load("/data/general/npcs/skeleton.lua")

local Talents = require("engine.interface.ActorTalents")

-- The boss , no "rarity" field means it will not be randomly generated
newEntity{ define_as = "GREATER_MUMMY_LORD",
	type = "undead", subtype = "mummy", unique = true,
	name = "Greater Mummy Lord",
	display = "Z", color=colors.VIOLET,
	desc = [[The wrappings of this mummy radiates with so much power it feels like wind is blowing from it.]],
	level_range = {20, 35}, exp_worth = 2,
	max_life = 250, life_rating = 21, fixed_rating = true,
	max_stamina = 200,
	max_mana = 200,
	stats = { str=25, dex=10, cun=8, mag=35, wil=20, con=20 },
	rank = 4,
	size_category = 2,
	open_door = true,
	infravision = 20,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="longsword", defined="LONGSWORD_RINGIL", autoreq=true},
		{type="armor", subtype="shield", ego_chance=100, autoreq=true},
		{type="armor", subtype="mummy", ego_chance=100, autoreq=true},
	},
	drops = resolvers.drops{chance=100, nb=4, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_SHIELD_PUMMEL]=3,
		[Talents.T_ASSAULT]=3,
		[Talents.T_OVERPOWER]=3,
		[Talents.T_BLINDING_SPEED]=3,
		[Talents.T_SWORD_MASTERY]=4,
		[Talents.T_WEAPON_COMBAT]=5,

		[Talents.T_FREEZE]=3,
		[Talents.T_ICE_STORM]=3,
		[Talents.T_INVISIBILITY]=3,

		[Talents.T_ROTTING_DISEASE]=3,
	},

	blind_immune = 1,
	see_invisible = 4,
	undead = 1,

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar" },
}

-- Some mummy minions
newEntity{ base = "BASE_NPC_MUMMY",
	name = "ancient elven mummy", color=colors.ANTIQUE_WHITE,
	desc = [[An animated corpse in mummy wrappings.]],
	level_range = {7, 50}, exp_worth = 1,
	rarity = 2,
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
	drops = resolvers.drops{chance=70, nb=1, {type="money"}, {} },
}

newEntity{ base = "BASE_NPC_MUMMY",
	name = "animated mummy wrappings", color=colors.SLATE, display='[',
	desc = [[An animated mummy wrappings, without a corpse inside... It seems like it can not move.]],
	level_range = {7, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(20,40), life_rating=4,
	ai_state = { talent_in=2, },
	never_move = 1,
	infravision = 20,

	resolvers.equip{
		{type="armor", subtype="mummy", ego_chance=100, autoreq=true},
	},
	autolevel = "caster",
	resolvers.talents{
		[Talents.T_MANATHRUST]=3,
		[Talents.T_FREEZE]=3,
		[Talents.T_LIGHTNING]=3,
		[Talents.T_STRIKE]=3,
	},
}

newEntity{ base = "BASE_NPC_MUMMY",
	name = "rotting mummy", color=colors.TAN,
	desc = [[An rotting animated corpse in mummy wrappings.]],
	level_range = {7, 50}, exp_worth = 1,
	rarity = 3,
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

