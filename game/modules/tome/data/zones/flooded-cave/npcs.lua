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

load("/data/general/npcs/aquatic_critter.lua")
load("/data/general/npcs/aquatic_demon.lua")

local Talents = require("engine.interface.ActorTalents")

-- The boss of trollshaws, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "UKLLMSWWIK",
	type = "dragon", subtype = "water", unique = true,
	name = "Ukllmswwik the wise",
	faction="water-lair",
	display = "D", color=colors.VIOLET,
	desc = [[It looks like a cross between a shark and a dragon, only nastier.]],
	level_range = {3, 40}, exp_worth = 2,
	max_life = 250, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	stats = { str=25, dex=10, cun=8, mag=10, con=20 },
	rank = 4,
	size_category = 4,
	can_breath={water=1},
	infravision = 20,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	drops = resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_STUN]=2, [Talents.T_KNOCKBACK]=1,
	},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=4, ai_move="move_astar", },

	can_talk = "ukllmswwik",
}
