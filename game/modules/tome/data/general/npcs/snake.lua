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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SNAKE",
	type = "animal", subtype = "snake",
	display = "J", color=colors.WHITE,
	body = { INVEN = 10 },
	sound_moam = {"creatures/snakes/snake_%d", 1, 4},
	sound_die = {"creatures/snakes/snake_die_%d", 1, 2},
	sound_random = {"creatures/snakes/snake_%d", 1, 4},

	infravision = 10,
	max_stamina = 110,
	rank = 2,
	size_category = 2,
	blind_immune = 1,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_snake" },
	global_speed_base = 1.3,
	stats = { str=14, dex=23, mag=5, con=5 },
	combat = {sound="creatures/snakes/snake_attack"},
	combat_armor = 1, combat_def = 1,
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_SNAKE",
	name = "large brown snake", color=colors.UMBER, image="npc/umber-snake.png",
	desc = [[This large snake hisses at you, angry at being disturbed.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(20,30),
	combat_armor = 1, combat_def = 3,
	combat = { dam=resolvers.levelup(2, 1, 0.7), atk=-2, apr=10 },
}

newEntity{ base = "BASE_NPC_SNAKE",
	name = "large white snake", color=colors.WHITE, image="npc/white-snake.png",
	desc = [[This large snake hisses at you, angry at being disturbed.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(20,30),
	combat_armor = 1, combat_def = 3,
	combat = { dam=resolvers.levelup(2, 1, 0.7), atk=-2, apr=10 },
}

newEntity{ base = "BASE_NPC_SNAKE",
	name = "copperhead snake", color=colors.SALMON, image="npc/salmon-snake.png",
	desc = [[It has a copper head and sharp venomous fangs.]],
	level_range = {2, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(30,40),
	combat_armor = 2, combat_def = 5,
	combat = { dam=resolvers.levelup(3, 1, 0.7), atk=0, apr=10 },

	resolvers.talents{ [Talents.T_BITE_POISON]=1 },
}

newEntity{ base = "BASE_NPC_SNAKE",
	name = "rattlesnake", color=colors.FIREBRICK, image="npc/firebrick-snake.png",
	desc = [[As you approach, the snake coils up and rattles its tail threateningly.]],
	level_range = {4, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(30,50),
	combat_armor = 2, combat_def = 8,
	combat = { dam=resolvers.levelup(5, 1, 0.7), atk=0, apr=10 },

	resolvers.talents{ [Talents.T_BITE_POISON]=1 },
}

newEntity{ base = "BASE_NPC_SNAKE",
	name = "king cobra", color=colors.GREEN, image="npc/green-snake.png",
	desc = [[It is a large snake with a hooded face.]],
	level_range = {5, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(40,70),
	combat_armor = 3, combat_def = 11,
	combat = { dam=resolvers.levelup(7, 1, 0.7), atk=2, apr=10 },

	resolvers.talents{ [Talents.T_BITE_POISON]=2 },
}

newEntity{ base = "BASE_NPC_SNAKE",
	name = "black mamba", color=colors.DARK_GREY, image="npc/darkgrey-snake.png",
	desc = [[It has glistening black skin, a sleek body, and highly venomous fangs.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(50,80),
	combat_armor = 4, combat_def = 12,
	combat = { dam=resolvers.levelup(10, 1, 0.7), atk=10, apr=10 },

	resolvers.talents{ [Talents.T_BITE_POISON]=3 },
	ingredient_on_death = "BLACK_MAMBA_HEAD",
}

newEntity{ base = "BASE_NPC_SNAKE",
	name = "anaconda", color=colors.YELLOW_GREEN, image="npc/yellow-green-snake.png",
	desc = [[You recoil in fear as you notice this huge, 10-meter-long snake.  It seeks to crush the life out of you.]],
	level_range = {20, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 14, combat_def = 5,
	combat = { dam=resolvers.levelup(12, 1, 0.7), atk=10, apr=10 },
	global_speed_base = 1,

	resolvers.talents{ [Talents.T_CONSTRICT]=5 },
}
