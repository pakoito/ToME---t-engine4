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

load("/data/general/npcs/rodent.lua", rarity(5))
load("/data/general/npcs/horror-corrupted.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_CORRUPTED_HORROR", define_as = "THE_MOUTH",
	unique = true,
	name = "The Mouth", tint=colors.PURPLE, image = "npc/the_mouth.png",
	color=colors.VIOLET,
	desc = [["From bellow, it devours."]],
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 12, fixed_rating = true,
	stats = { str=10, dex=10, cun=12, mag=20, con=10 },
	rank = 4,
	size_category = 4,
	infravision = 20,
	instakill_immune = 1,
	never_move = true,

	-- Bad idea to melee it
	combat = {dam=100, atk=1000, apr=1000, physcrit=1000},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="RING_OF_HORRORS", random_art_replace={chance=75}} },
	resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_CALL_OF_AMAKTHEL]=1,
		[Talents.T_DRAIN]=1,
	},

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("deep-bellow", engine.Quest.COMPLETED)
	end,
}
