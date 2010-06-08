-- ToME - Tales of Middle-Earth
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
	type = "giant", subtype = "xorn",
	display = "X", color=colors.UMBER,

	combat = { dam=resolvers.rngavg(15,20), atk=15, apr=15, dammod={str=0.8} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=60, nb=1, {type="money"} },

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

	confusion_immune = 1,
	poison_immune = 1,
}

newEntity{ base = "BASE_NPC_XORN",
	name = "Umber Hulk", color=colors.UMBER,
	desc = [[This bizarre creature has glaring eyes and large mandibles capable of slicing through rock.]],
	level_range = {10, 50}, exp_worth = 1,
	rarity = 12,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 15, combat_def = 0,
	resolvers.talents{ [Talents.T_MIND_DISRUPTION]=2, },
}
