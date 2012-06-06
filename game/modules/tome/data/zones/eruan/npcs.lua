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

load("/data/general/npcs/sandworm.lua", rarity(0))
load("/data/general/npcs/ritch.lua", rarity(0))
load("/data/general/npcs/orc.lua", rarity(6))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "SUN_PALADIN_GUREN",
	type = "humanoid", subtype = "human",
	display = "p",
	faction = "sunwall",
	name = "Sun Paladin Guren", color=colors.GOLD, unique = true,
	desc = [[A Human warrior, clad in shining plate armour. Power radiates from him.]],
	level_range = {50, nil}, exp_worth = 2,
	life_regen = 10,
	rank = 3,
	size_category = 3,
	female = true,
	max_life = 150, life_rating = 27, fixed_rating = true,
	infravision = 10,
	stats = { str=15, dex=10, cun=12, mag=16, con=14 },
	move_others=true,

	open_door = true,
	invulnerable = 1,

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_astar", },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.equip{
		{type="weapon", subtype="mace", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="shield", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="massive", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]=5,
		[Talents.T_CHANT_OF_LIGHT]=5,
		[Talents.T_SEARING_LIGHT]=5,
		[Talents.T_MARTYRDOM]=5,
		[Talents.T_BARRIER]=5,
		[Talents.T_WEAPON_OF_LIGHT]=5,
	},
	resolvers.sustains_at_birth(),

	can_talk = "pre-charred-scar-eruan",
}
