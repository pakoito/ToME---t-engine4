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

load("/data/general/npcs/minor-demon.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")

-- The boss of Amon Sul, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "CORRUPTED_BALROG",
	type = "demon", subtype = "major", unique = true,
	name = "Corrupted Balrog",
	display = "U", color=colors.VIOLET,
	desc = [[Shadow and flames. The huge beast of fire moves speedily toward you, its huge shadowy wings deployed.]],
	level_range = {40, 55}, exp_worth = 2,
	max_life = 250, life_rating = 25, fixed_rating = true,
	rank = 4,
	size_category = 5,
	infravision = 20,
	stats = { str=16, dex=12, cun=14, mag=25, con=16 },
	instakill_immune = 1,
	no_breath = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="light", autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_MANATHRUST]=4, [Talents.T_FREEZE]=4, [Talents.T_TIDAL_WAVE]=2,
		[Talents.T_SWORD_MASTERY]=3, [Talents.T_STUNNING_BLOW]=1,
	},

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar" },

	on_die = function(self, who)
	end,
}

newEntity{ define_as = "LIMMIR",
	type = "humanoid", subtype = "elf",
	display = "p",
	faction = "sunwall",
	name = "Limmir the Jeweler", color=colors.RED, unique = true,
	desc = [[An elf anorithil, specialized in the art of jewelry.]],
	level_range = {50, 50}, exp_worth = 2,
	rank = 3,
	size_category = 3,
	max_life = 150, life_rating = 17, fixed_rating = true,
	infravision = 20,
	stats = { str=15, dex=10, cun=12, mag=16, con=14 },
	move_others=true,
	knockback_immune = 1,

	open_door = true,

	autolevel = "caster",
	ai = "none", ai_state = { },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	resolvers.talents{
		[Talents.T_CHANT_OF_LIGHT]=5,
		[Talents.T_HYMN_OF_SHADOWS]=5,
	},
	resolvers.sustains_at_birth(),

	can_talk = "limmir-valley-moon",
	can_craft = true,
}
