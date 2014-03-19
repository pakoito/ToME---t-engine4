-- ToME - Tales of Maj'Eyal
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

local Talents = require("engine.interface.ActorTalents")

newEntity{ --rodent base
	define_as = "BASE_NPC_RODENT",
	type = "vermin", subtype = "rodent",
	display = "r", color=colors.WHITE,
	can_multiply = 2,
	body = { INVEN = 10 },
	infravision = 10,
	sound_moam = {"creatures/rats/rat_hurt_%d", 1, 2},
	sound_die = {"creatures/rats/rat_die_%d", 1, 2},
	sound_random = {"creatures/rats/rat_%d", 1, 3},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=8, dex=15, mag=3, con=5 },
	combat = {sound="creatures/rats/rat_attack"},
	combat_armor = 1, combat_def = 1,
	rank = 1,
	size_category = 1,
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant white mouse", color=colors.WHITE,
	level_range = {1, 3}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=10 },
	resolvers.talents{
		[Talents.T_STEALTH]={base=0, every=2, max=5},
		[Talents.T_HIDE_IN_PLAIN_SIGHT]={base=0, every=2, max=5},
		[Talents.T_SHADOWSTRIKE]={base=0, every=2, max=5},
	},
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant brown mouse", color=colors.UMBER,
	level_range = {1, 3}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=10 },
	resolvers.talents{
		[Talents.T_STEALTH]={base=0, every=2, max=5},
		[Talents.T_HIDE_IN_PLAIN_SIGHT]={base=0, every=2, max=5},
		[Talents.T_SHADOWSTRIKE]={base=0, every=2, max=5},
	},
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant white rat", color=colors.WHITE,
	level_range = {1, 4}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(15,20),
	combat = { dam=7, atk=0, apr=10 },
	resolvers.talents{
		[Talents.T_NIMBLE_MOVEMENTS]={base=0, every=3, max=5},
		[Talents.T_LACERATING_STRIKES]={base=0, every=3, max=5},
	},
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant brown rat", color=colors.UMBER,
	level_range = {1, 4}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(15,20),
	combat = { dam=7, atk=0, apr=10 },
	resolvers.talents{
		[Talents.T_NIMBLE_MOVEMENTS]={base=0, every=3, max=5},
		[Talents.T_LACERATING_STRIKES]={base=0, every=3, max=5},
	},
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant rabbit", color=colors.UMBER,
	desc = [[Kill the wabbit, kill the wabbit, kill the wabbbbbiiiiiit.]],
	level_range = {1, 4}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(20,30),
	combat = { dam=8, atk=0, apr=10 },
	resolvers.talents{
		[Talents.T_EVASION]={base=1, every=3, max=5},
		[Talents.T_DISENGAGE]={base=1, every=3, max=5},
	},
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant crystal rat", color=colors.PINK,
	desc = [[Instead of fur, this rat has crystals growing on its back, which provide extra protection.]],
	level_range = {1, 5}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(35,50),
	combat = { dam=7, atk=0, apr=10 },
	combat_armor = 4, combat_def = 2,
	resolvers.talents{
		[Talents.T_STONE_SKIN]={base=1, every=4, max=5},
		[Talents.T_STRIKE]={base=0, every=4, max=5},
	},
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant grey mouse", color=colors.SLATE,
	level_range = {1, 3}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=10 },
	resolvers.talents{
		[Talents.T_CRAWL_POISON]={base=1, every=3, max=5},
	},
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant grey rat", color=colors.SLATE,
	level_range = {1, 4}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(15,20),
	combat = { dam=7, atk=0, apr=10 },
	resolvers.talents{
		[Talents.T_CRAWL_POISON]={base=1, every=2, max=5},
		[Talents.T_SPIT_POISON]={base=0, every=3, max=5},
	},
}
