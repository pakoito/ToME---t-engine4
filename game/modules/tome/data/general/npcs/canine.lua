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

-- last updated:  5:11 PM 1/29/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_CANINE",
	type = "animal", subtype = "canine",
	display = "C", color=colors.WHITE,
	body = { INVEN = 10 },
	sound_moam = {"creatures/wolves/wolf_hurt_%d", 1, 2},
	sound_die = {"creatures/wolves/wolf_hurt_%d", 1, 1},
	sound_random = {"creatures/wolves/wolf_howl_%d", 1, 3},

	max_stamina = 150,
	rank = 1,
	size_category = 2,
	infravision = 10,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
	global_speed_base = 1.2,
	stats = { str=10, dex=17, mag=3, con=7 },
	combat = { dammod={str=0.6}, sound="creatures/wolves/wolf_attack_1" },
	combat_armor = 1, combat_def = 1,
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "wolf", color=colors.UMBER, image="npc/canine_w.png",
	desc = [[Lean, mean, and shaggy, it stares at you with hungry eyes.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(40,70),
	combat_armor = 1, combat_def = 3,
	combat = { dam=resolvers.levelup(5, 1, 0.7), atk=0, apr=3 },
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "great wolf", color=colors.UMBER, image="npc/canine_gw.png",
	desc = [[Larger than a normal wolf, it prowls and snaps at you.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(60,90),
	combat_armor =2, combat_def = 4,
	combat = { dam=resolvers.levelup(6, 1, 0.8), atk=0, apr=3 },
	resolvers.talents{ [Talents.T_HOWL]=1, },
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "dire wolf", color=colors.DARK_UMBER, image="npc/canine_dw.png",
	desc = [[Easily as big as a horse, this wolf menaces you with its claws and fangs.]],
	level_range = {4, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(80,110),
	combat_armor = 3, combat_def = 5,
	combat = { dam=resolvers.levelup(9, 1, 0.9), atk=5, apr=4 },
	resolvers.talents{ [Talents.T_HOWL]=1, },
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "white wolf", color=colors.WHITE, image="npc/canine_ww.png",
	desc = [[A large and muscled wolf from the northern wastes. Its breath is cold and icy, and its fur coated in frost.]],
	level_range = {4, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,100),
	combat_armor = 3, combat_def = 4,
	combat = { dam=resolvers.levelup(8, 1, 0.9), atk=5, apr=3 },
	resolvers.talents{ [Talents.T_HOWL]=2, },

	resists = { [DamageType.FIRE] = -50, [DamageType.COLD] = 100 },
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "warg", color=colors.BLACK, image="npc/canine_warg.png",
	desc = [[It is a large wolf with eyes full of cunning.]],
	level_range = {6, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(60,100),
	combat_armor = 5, combat_def = 7,
	combat = { dam=resolvers.levelup(10, 1, 1), atk=10, apr=5 },
	resolvers.talents{ [Talents.T_HOWL]=3, },
	ingredient_on_death = "WARG_CLAW",
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "fox", color=colors.RED, image="npc/canine_fox.png",
	desc = [[The quick brown fox jumps over the lazy dog.]],
	sound_moam = {"creatures/foxes/bark_hurt_%d", 1, 1},
	sound_die = {"creatures/wolves/death_%d", 1, 1},
	sound_random = {"creatures/wolves/bark_%d", 1, 2},
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(40,50),
	combat_armor = 1, combat_def = 3,
	combat = { dam=resolvers.levelup(4, 1, 0.7), atk=0, apr=3, sound="creatures/foxes/attack_1" },
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "Rungof the Warg Titan", color=colors.VIOLET, unique=true, image="npc/canine_rungof.png",
	desc = [[It is a large wolf with eyes full of cunning, thrice the size of a normal warg.]],
	level_range = {20, nil}, exp_worth = 2,
	rank = 3.5,
	size_category = 4,
	rarity = 50,
	max_life = 220,
	combat_armor = 25, combat_def = 0,
	combat = { dam=resolvers.levelup(20, 1, 1.3), atk=20, apr=16 },

	ai = "tactical",

	make_escort = {
		{type="animal", subtype="canine", name="warg", number=6},
	},
	resolvers.talents{
		[Talents.T_HOWL]=5,
		[Talents.T_RUSH]=3,
		[Talents.T_CRIPPLE]=3,
	},
}
