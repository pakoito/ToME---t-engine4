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

-- last updated:  7:34 PM 2/2/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_PLANT",
	type = "immovable", subtype = "plants",
	display = "#", color=colors.WHITE,
	blood_color = colors.GREEN,
	desc = "A not-so-strange growth on the dungeon floor.",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	stats = { str=10, dex=10, mag=3, con=10 },
	infravision = 10,
	combat_armor = 1, combat_def = 1,
	rank = 1,
	size_category = 1,
	never_move = 1,
	fear_immune = 1,
	not_power_source = {arcane=true, technique=true},
}

newEntity{ base = "BASE_NPC_PLANT",
	name = "giant venus flytrap", color=colors.GREEN,
	desc = "This flesh-eating plant has grown to enormous proportions and seeks to quell its hunger.",
	level_range = {7, 17}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=15, apr=10 },
}

newEntity{ base = "BASE_NPC_PLANT",
	name = "treant", color=colors.GREEN,
	desc = "A very strong near-sentient tree, which has become hostile to other living things.",
	sound_moam = "creatures/treants/treeant_2",
	sound_die = {"creatures/treants/treeant_death_%d", 1, 2},
	sound_random = {"creatures/treants/treeant_%d", 1, 3},
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/immovable_plants_treant.png", display_h=2, display_y=-1}}},
	level_range = {12, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(100,130),
	life_rating = 15,
	combat = { dam=resolvers.levelup(resolvers.rngavg(8,13), 1, 1.2), atk=15, apr=5, sound="actions/melee_thud" },
	never_move = 0,
	rank = 2,
	size_category = 5,
}

newEntity{ base = "BASE_NPC_PLANT",
	name = "poison ivy", color=colors.GREEN,
	desc = "This harmless little plant makes you all itchy.",
	level_range = {3, 25}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(1,1),
	combat = { dam=3, atk=15, apr=3, damtype=DamageType.POISON},
	can_multiply = 2,

	on_melee_hit = {[DamageType.POISON]=5},
}

newEntity{ base = "BASE_NPC_PLANT",
	name = "honey tree", color=colors.UMBER,
	desc = "As you approach it, you hear a high-pitched buzzing sound.",
	sound_moam = "creatures/treanst/treeant_2",
	sound_die = {"creatures/treants/treeant_death_%d", 1, 2},
	sound_random = {"creatures/treants/treeant_%d", 1, 3},
	level_range = {10, 24}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(100,130),
	life_rating = 15,
	combat = false,
	rank = 2,
	size_category = 5,

	summon = {
		{type="insect", subtype="swarms", name="bee swarm", number=1, hasxp=false},
		{type="insect", subtype="swarms", name="bee swarm", number=1, hasxp=false},
		{type="insect", subtype="swarms", name="bee swarm", number=1, hasxp=false},
		{type="insect", subtype="swarms", name="bee swarm", number=2, hasxp=false},
		{type="insect", subtype="swarms", name="bee swarm", number=2, hasxp=false},
		{type="animal", subtype="bear", number=1, hasxp=false},
	},

	resolvers.talents{ [Talents.T_SUMMON]=1 },
	ingredient_on_death = "HONEY_TREE_ROOT",
}
