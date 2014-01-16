-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

-- last updated:  5:11 PM 1/29/2010

newEntity{
	define_as = "BASE_NPC_CANINE",
	type = "animal", subtype = "canine",
	display = "C", color=colors.WHITE,
	level_range = {1, nil}, exp_worth = 1,

	ai = "dumb_talented_simple", ai_state = { talent_in=2, },
	energy = { mod=1.1 },
	combat = { dammod={str=0.6} },
	combat_armor = 1, combat_def = 1,
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "wolf", color=colors.UMBER, image="npc/canine_w.png",
	desc = [[Lean, mean, and shaggy, it stares at you with hungry eyes.]],
	rarity = 1,
	max_life = resolvers.rngavg(40,70),
	combat_armor = 1, combat_def = 3,
	combat = { dam=5, atk=15, apr=3 },
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "white wolf", color=colors.WHITE, image="npc/canine_ww.png",
	desc = [[A large and muscled wolf from the northern wastes. Its breath is cold and icy and its fur coated in frost.]],
	rarity = 3,
	max_life = resolvers.rngavg(70,100),
	combat_armor = 3, combat_def = 4,
	combat = { dam=8, atk=15, apr=3 },
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "warg", color=colors.BLACK, image="npc/canine_warg.png",
	desc = [[It is a large wolf with eyes full of cunning.]],
	rarity = 4,
	max_life = resolvers.rngavg(60,100),
	combat_armor = 5, combat_def = 7,
	combat = { dam=10, atk=17, apr=5 },
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "fox", color=colors.RED, image="npc/canine_fox.png",
	desc = [[The quick brown fox jumps over the lazy dog.]],
	rarity = 3,
	max_life = resolvers.rngavg(40,50),
	combat_armor = 1, combat_def = 3,
	combat = { dam=4, atk=10, apr=3 },
}
