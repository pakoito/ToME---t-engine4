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
	define_as = "BASE_NPC_WORM",
	type = "vermin", subtype = "worms",
	display = "w", color=colors.WHITE,
	can_multiply = 4,
	body = { INVEN = 10 },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	energy = { mod=0.9 },
	stats = { str=10, dex=15, mag=3, con=3 },
	combat_armor = 1, combat_def = 1,
	size_category = 1,
}

newEntity{ base = "BASE_NPC_WORM",
	name = "white worm mass", color=colors.WHITE,
	level_range = {1, 15}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=1, atk=15, apr=100 },

	resolvers.talents{ [Talents.T_CRAWL_POISON]=1, [Talents.T_MULTIPLY]=1 },
}

newEntity{ base = "BASE_NPC_WORM",
	name = "green worm mass", color=colors.GREEN,
	level_range = {2, 15}, exp_worth = 1,
	rarity = 5,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=1, atk=15, apr=100 },

	resolvers.talents{ [Talents.T_CRAWL_ACID]=2, [Talents.T_MULTIPLY]=1 },
}
