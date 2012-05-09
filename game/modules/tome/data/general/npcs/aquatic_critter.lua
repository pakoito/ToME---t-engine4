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

-- last updated:  10:46 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_AQUATIC_CRITTER",
	type = "aquatic", subtype = "critter",
	display = "A", color=colors.WHITE,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	stats = { str=12, dex=10, mag=3, con=13 },
	combat_armor = 1, combat_def = 1,
	combat = { dam=resolvers.levelup(resolvers.mbonus(36, 10), 1, 1), atk=15, apr=7, dammod={str=0.6} },
	max_life = resolvers.rngavg(10,20), life_rating = 6,
	infravision = 10,
	rank = 1,
	size_category = 2,
	can_breath={water=1},

	resists = { [DamageType.COLD] = 25, },
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_AQUATIC_CRITTER",
	name = "giant eel", color=colors.CADET_BLUE,
	desc = "A snake-like being, moving toward you.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
}

newEntity{ base = "BASE_NPC_AQUATIC_CRITTER",
	name = "electric eel", color=colors.STEEL_BLUE,
	desc = "A snake-like being, radiating electricity.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 4,
	autolevel = "warriormage",
	combat = {damtype=DamageType.LIGHTNING},
	resolvers.talents{ [Talents.T_CHAIN_LIGHTNING]=3, [Talents.T_LIGHTNING]=3 },
	ingredient_on_death = "ELECTRIC_EEL_TAIL",
}

newEntity{ base = "BASE_NPC_AQUATIC_CRITTER",
	name = "dragon turtle", color=colors.DARK_SEA_GREEN,
	desc = "A huge, elongated sea-green reptile.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 5,
	rank = 2,
	stats = { str=22, dex=10, mag=3, con=13 },
	resists = { [DamageType.PHYSICAL] = 50, },
}

newEntity{ base = "BASE_NPC_AQUATIC_CRITTER",
	name = "ancient dragon turtle", color=colors.DARK_SEA_GREEN,
	desc = "A huge, elongated sea-green reptile, it looks old and impenetrable.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/aquatic_critter_ancient_dragon_turtle.png", display_h=2, display_y=-1}}},
	level_range = {20, nil}, exp_worth = 1,
	rarity = 10,
	rank = 3,
	autolevel = "warriormage",
	resists = { [DamageType.PHYSICAL] = 60, },
	resolvers.talents{ [Talents.T_TIDAL_WAVE]=3, [Talents.T_FREEZE]=3 },

	ai = "tactical",
}

newEntity{ base = "BASE_NPC_AQUATIC_CRITTER",
	name = "squid", color=colors.TEAL,
	desc = "Darting its many tentacles toward you, it tries to lock you down.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	resolvers.talents{ [Talents.T_GRAB]=3, },
	ingredient_on_death = "SQUID_INK",
}

newEntity{ base = "BASE_NPC_AQUATIC_CRITTER",
	name = "ink squid", color=colors.LIGHT_STEEL_BLUE,
	desc = "Darting its many tentacles toward you, it tries to blind you with its murky ink.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 2,
	stats = { mag=30, },
	resolvers.talents{ [Talents.T_GRAB]=3, [Talents.T_BLINDING_INK]=3, },
	ingredient_on_death = "SQUID_INK",
}
