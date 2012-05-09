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
	define_as = "BASE_NPC_RITCH",
	type = "insect", subtype = "ritch",
	display = "I", color=colors.RED,
	blood_color = colors.GREEN,
	desc = [[Ritches are giant insects native to the arid wastes of the southern parts of the Far East.
Vicious predators, they inject corrupting diseases into their foes, and their sharp claws cut through most armours.]],

	combat = { dam=resolvers.levelup(resolvers.rngavg(30,35), 1, 1), atk=16, apr=70, damtype=DamageType.BLIGHT, dammod={dex=1.2} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 10,
	size_category = 1,
	rank = 2,

	autolevel = "slinger",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	global_speed_base = 1.2,
	stats = { str=15, dex=15, mag=8, con=10 },

	poison_immune = 0.5,
	disease_immune = 0.5,
	resists = { [DamageType.BLIGHT] = 20, [DamageType.FIRE] = 100 },
	ingredient_on_death = "RITCH_STINGER",
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_RITCH",
	name = "ritch larva", color=colors.DARK_RED,
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 50,
	life_rating = 6,

	rank = 1,
	combat_armor = 5, combat_def = 5,

	resolvers.talents{
		[Talents.T_ROTTING_DISEASE]={base=3, every=7, max=6},
		[Talents.T_SHRIEK]=1,
	},
}

newEntity{ base = "BASE_NPC_RITCH",
	name = "ritch hunter", color=colors.RED,
	level_range = {30, nil}, exp_worth = 1,
	rarity = 2,
	max_life = 120,
	life_rating = 10,

	rank = 2,
	combat_armor = 12, combat_def = 5,

	resolvers.talents{
		[Talents.T_ROTTING_DISEASE]={base=4, every=7, max=8},
		[Talents.T_RUSH]=5,
		[Talents.T_FLAME]={base=5, every=7, max=9},
		[Talents.T_SHRIEK]=3,
	},

}

newEntity{ base = "BASE_NPC_RITCH",
	name = "ritch hive mother", color=colors.light_RED,
	level_range = {32, nil}, exp_worth = 1,
	rarity = 4,
	max_life = 250,
	life_rating = 12,

	rank = 3,
	size_category = 2,
	combat_armor = 20, combat_def = 20,

	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",

	make_escort = {
		{type="insect", subtype="ritch", number=3, no_subescort=true},
	},
	summon = {
		{type="insect", subtype="ritch", number=1, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_ROTTING_DISEASE]={base=5, every=7, max=9},
		[Talents.T_FLAME]={base=5, every=7, max=9},
		[Talents.T_SUMMON]=1,
		[Talents.T_SHRIEK]=4,
	},

}
