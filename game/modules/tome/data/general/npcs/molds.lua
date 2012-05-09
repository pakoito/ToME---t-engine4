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
	define_as = "BASE_NPC_MOLD",
	type = "immovable", subtype = "molds",
	display = "m", color=colors.WHITE,
	blood_color = colors.PURPLE,
	desc = "A strange growth on the dungeon floor.",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	stats = { str=10, dex=15, mag=3, con=3 },
	global_speed_base = 0.6,
	infravision = 10,
	combat_armor = 1, combat_def = 1,
	never_move = 1,
	blind_immune = 1,
	poison_immune = 1,
	fear_immune = 1,
	no_breath = 1,
	rank = 1,
	size_category = 1,
	not_power_source = {technique_ranged=true},
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "grey mold", color=colors.SLATE,
	desc = "A strange grey growth on the dungeon floor.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=10 },
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "brown mold", color=colors.UMBER,
	desc = "A strange brown growth on the dungeon floor.",
	level_range = {2, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=10 },
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "shining mold", color=colors.YELLOW,
	desc = "A strange luminescent growth on the dungeon floor.",
	level_range = {3, 25}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(1,1),
	combat = { dam=5, atk=5, apr=10 },

	resolvers.talents{ [Talents.T_SPORE_BLIND]=1 },
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "green mold", color=colors.GREEN,
	desc = "A strange sickly green growth on the dungeon floor.",
	level_range = {5, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=10, apr=10 },
	resolvers.talents{ [Talents.T_SPORE_POISON]=1 },
}

newEntity{ base = "BASE_NPC_MOLD",
	unique = true,
	type = "undead", subtype = "molds",
	name = "Z'quikzshl the skeletal mold", image = "npc/immovable_molds_skeletal_mold.png",
	display = 'm', color=colors.PURPLE,
	desc = [[Steeped in fungal malevolence, this mold refused to die.  How a mold becomes a skeleton, though, is beyond you.  Are those its own bones, or the bones of hapless adventurers?]],

	level_range = {10, nil}, exp_worth = 5,
	rarity = 50,
	max_life = resolvers.rngavg(120,150),
	combat = { dam=resolvers.mbonus(30, 20), atk=25, apr=15 },

	rank = 3.5,
	size_category = 2,

	summon = {
		{type="immovable", subtype="molds", number=4, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_SUMMON]=1,
		[Talents.T_BONE_SPEAR]=4,
		[Talents.T_BONE_GRAB]=3,
		[Talents.T_SPORE_BLIND]=5,
		[Talents.T_SPORE_POISON]=5,
		[Talents.T_ROTTING_DISEASE]=5,
		[Talents.T_DECREPITUDE_DISEASE]=5,
		[Talents.T_WEAKNESS_DISEASE]=5,
		[Talents.T_GRAB]=5,
	},

	on_death_lore = "zquikzshl",
}
