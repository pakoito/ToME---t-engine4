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
	define_as = "BASE_NPC_AQUATIC_DEMON",
	type = "aquatic", subtype = "demon",
	display = "U", color=colors.WHITE,
	blood_color = colors.GREEN,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	stats = { str=12, dex=10, mag=3, con=13 },
	combat_armor = 1, combat_def = 1,
	combat = { dam=resolvers.levelup(resolvers.mbonus(46, 20), 1, 1), atk=15, apr=7, dammod={str=0.7} },
	max_life = resolvers.rngavg(100,120),
	infravision = 10,
	demon = 1,
	open_door = true,
	rank = 2,
	size_category = 3,
	can_breath={water=1},
}

newEntity{ base = "BASE_NPC_AQUATIC_DEMON",
	name = "water imp", color=colors.YELLOW_GREEN,
	display = "u",
	desc = "A small water demon, lobbing spells at you.",
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	size_category = 1,
	autolevel = "caster",
	combat_armor = 1, combat_def = 0,
	combat = {damtype=DamageType.ICE},

	resists={[DamageType.COLD] = resolvers.mbonus(12, 5)},

	resolvers.talents{ [Talents.T_WATER_BOLT]=3, [Talents.T_PHASE_DOOR]=2, },
}

newEntity{ base = "BASE_NPC_AQUATIC_DEMON",
	name = "Walrog", color=colors.DARK_SEA_GREEN, unique=true,
	desc = "Walrog, the lord of Water",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/aquatic_demon_walrog.png", display_h=2, display_y=-1}}},
	level_range = {20, 30}, exp_worth = 1,
	rarity = 50,
	rank = 3.5,
	life_rating = 16,
	autolevel = "warriormage",
	combat_armor = 45, combat_def = 0,
	combat_dam = 55,
	combat = {damtype=DamageType.ICE},

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	resists={[DamageType.COLD] = resolvers.mbonus(50, 30)},

	resolvers.talents{ [Talents.T_TIDAL_WAVE]=4, [Talents.T_FREEZE]=5 },

	on_death_lore = "walrog",
}
