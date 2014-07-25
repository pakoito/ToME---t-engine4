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

newEntity{
	define_as = "BASE_NPC_SHIVGOROTH",
	type = "elemental", subtype = "ice",
	blood_color = colors.BLUE,
	display = "E", color=colors.BLUE,

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 15), 1, 1.2), atk=15, apr=15, dammod={mag=0.8}, damtype=DamageType.COLD },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 10,
	life_rating = 8,
	rank = 2,
	size_category = 3,
	levitation = 1,
	power_source = {arcane=true},

	autolevel = "dexmage",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	stats = { str=10, dex=8, mag=6, con=16 },

	resists = { [DamageType.PHYSICAL] = 10, [DamageType.COLD] = 100, [DamageType.FIRE] = -30, },
	damage_affinity = { [DamageType.COLD] = 70 },

	no_breath = 1,
	poison_immune = 1,
	cut_immune = 1,
	disease_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	knockback_immune = 1,
	confusion_immune = 1,
}

newEntity{ base = "BASE_NPC_SHIVGOROTH",
	name = "shivgoroth", color=colors.BLUE,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/elemental_ice_shivgoroth.png", display_h=2, display_y=-1}}},
	desc = [[Shivgoroth are mighty ice elementals, torn away from their home world by a powerful magic.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.COLD] = resolvers.mbonus(20, 10), },

	resolvers.talents{
		[Talents.T_GLACIAL_VAPOUR]={base=3, every=10, max=7},
	},
}

newEntity{ base = "BASE_NPC_SHIVGOROTH",
	name = "greater shivgoroth", color=colors.DARK_BLUE,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/elemental_ice_greater_shivgoroth.png", display_h=2, display_y=-1}}},
	desc = [[Shivgoroth are mighty ice elementals, torn away from their home world by a powerful magic.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80), life_rating = 10,
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.COLD] = resolvers.mbonus(20, 10), },

	resolvers.talents{
		[Talents.T_GLACIAL_VAPOUR]={base=4, every=10, max=8},
		[Talents.T_ICE_SHARDS]={base=3, every=10, max=7},
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_SHIVGOROTH",
	name = "ultimate shivgoroth", color=colors.CADET_BLUE,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/elemental_ice_ultimate_shivgoroth.png", display_h=2, display_y=-1}}},
	desc = [[Shivgoroth are mighty ice elementals, torn away from their home world by a powerful magic.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.COLD] = resolvers.mbonus(20, 10), },

	ai = "tactical",

	resolvers.talents{
		[Talents.T_GLACIAL_VAPOUR]={base=4, every=7},
		[Talents.T_ICE_SHARDS]={base=4, every=7},
		[Talents.T_FROZEN_GROUND]={base=3, every=7},
		[Talents.T_ICE_STORM]={base=3, every=7},
	},
	resolvers.sustains_at_birth(),
}
