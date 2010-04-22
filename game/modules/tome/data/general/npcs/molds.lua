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
	define_as = "BASE_NPC_MOLD",
	type = "immovable", subtype = "molds",
	display = "m", color=colors.WHITE,
	desc = "A strange growth on the dungeon floor.",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	stats = { str=10, dex=15, mag=3, con=3 },
	energy = { mod=0.5 },
	combat_armor = 1, combat_def = 1,
	never_move = 1,
	fear_immune = 1,
	size_category = 1,
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "grey mold", color=colors.SLATE,
	desc = "A strange brey growth on the dungeon floor.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=10 },
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "brown mold", color=colors.UMBER,
	desc = "A strange brown growth on the dungeon floor.",
	level_range = {2, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=10 },
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "shining mold", color=colors.YELLOW,
	desc = "A strange luminescent growth on the dungeon floor.",
	level_range = {3, 25}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(1,1),
	combat = { dam=5, atk=15, apr=10 },

	resolvers.talents{ [Talents.T_SPORE_BLIND]=1 },
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "green mold", color=colors.GREEN,
	desc = "A strange sickly green growth on the dungeon floor.",
	level_range = {5, 25}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=10 },
	resolvers.talents{ [Talents.T_SPORE_POISON]=1 },
}
