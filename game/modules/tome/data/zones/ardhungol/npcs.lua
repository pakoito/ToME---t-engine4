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

load("/data/general/npcs/spider.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "UNGOLE", base = "BASE_NPC_SPIDER",
	name = "Ungolë", color=colors.VIOLET, unique = true,
	desc = [[A huge spider, shed in darkness, with red glowing eyes darting at you. She looks hungry.]],
	level_range = {30, 45}, exp_worth = 2,
	max_life = 450, life_rating = 15, fixed_rating = true,
	stats = { str=25, dex=10, cun=47, mag=10, con=20 },
	rank = 4,
	size_category = 4,
	infravision = 20,

	combat_armor = 17, combat_def = 17,
	resists = { [DamageType.FIRE] = 20, [DamageType.ACID] = 20, [DamageType.COLD] = 20, [DamageType.LIGHTNING] = 20, },

	combat = { dam=resolvers.rngavg(40,58), atk=16, apr=9, damtype=DamageType.NATURE, dammod={str=0.8} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },
	resolvers.drops{chance=100, nb=1, {type="wand", subtype="wand", defined="ROD_SPYDRIC_POISON"} },

	resolvers.talents{
		[Talents.T_KNOCKBACK]=4,
		[Talents.T_DARKNESS]=5,
		[Talents.T_SPIT_POISON]=5,
		[Talents.T_SPIDER_WEB]=5,
		[Talents.T_LAY_WEB]=5,

		[Talents.T_CORROSIVE_VAPOUR]=5,
		[Talents.T_PHANTASMAL_SHIELD]=5,
	},


	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_astar", },

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("spydric-infestation", engine.Quest.COMPLETED)
	end,
}
