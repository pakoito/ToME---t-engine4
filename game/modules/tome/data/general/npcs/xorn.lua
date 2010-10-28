-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
	define_as = "BASE_NPC_XORN",
	type = "elemental", subtype = "xorn",
	display = "X", color=colors.UMBER,

	combat = { dam=resolvers.mbonus(46, 15), atk=15, apr=15, dammod={str=0.8} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {type="money"} },
	resolvers.drops{chance=60, nb=1, {type="money"} },
	resolvers.drops{chance=40, nb=1, {type="money"} },

	can_pass = {pass_wall=20},

	infravision = 20,
	life_rating = 12,
	max_stamina = 90,
	rank = 2,
	size_category = 4,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_target="target_player_radius", sense_radius=6, talent_in=3, },
	energy = { mod=1 },
	stats = { str=20, dex=8, mag=6, con=16 },

	resists = { [DamageType.PHYSICAL] = 20, [DamageType.FIRE] = 50, },

	no_breath = 1,
	confusion_immune = 1,
	poison_immune = 1,
	stone_immune = 1,
}

newEntity{ base = "BASE_NPC_XORN",
	name = "umber hulk", color=colors.LIGHT_UMBER,
	desc = [[This bizarre creature has glaring eyes and large mandibles capable of slicing through rock.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 12, combat_def = 0,
	move_project = {[DamageType.DIG]=1},
	resolvers.talents{ [Talents.T_MIND_DISRUPTION]=2, },
}

newEntity{ base = "BASE_NPC_XORN",
	name = "xorn", color=colors.UMBER,
	desc = [[A huge creature of the element Earth. Able to merge with its element, it has four huge arms protruding from its enormous torso.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(130,140),
	combat_armor = 15, combat_def = 10,
	combat = { damtype=DamageType.ACID },
	resolvers.talents{ [Talents.T_CONSTRICT]=4, },
}

newEntity{ base = "BASE_NPC_XORN",
	name = "xaren", color=colors.SLATE,
	desc = [[It is a tougher relative of the Xorn. Its hide glitters with metal ores.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(130,140),
	combat_armor = 15, combat_def = 10,
	combat = { damtype=DamageType.ACID },
	resolvers.talents{ [Talents.T_CONSTRICT]=4, [Talents.T_RUSH]=2, },
}
