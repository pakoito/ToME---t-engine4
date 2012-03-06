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

load("/data/general/npcs/bear.lua", rarity(0))
load("/data/general/npcs/vermin.lua", rarity(3))
load("/data/general/npcs/canine.lua", rarity(1))
load("/data/general/npcs/snake.lua", rarity(0))
load("/data/general/npcs/plant.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_BEAR", define_as = "NORGOS",
	allow_infinite_dungeon = true,
	unique = true,
	name = "Norgos, the Guardian",
	display = "q", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/animal_bear_norgos_the_guardian.png", display_h=2, display_y=-1}}},
	desc = [[This ancient bear long guarded the western side of the forest, but as of late he started growing mad, attacking even the thaloren.]],
	killer_message = "and was feasted upon by wolves",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 200, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	max_mana = 200,
	stats = { str=25, dex=15, cun=8, mag=10, wil=20, con=20 },
	rank = 4,
	size_category = 5,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	combat = { dam=resolvers.levelup(17, 1, 0.8), atk=10, apr=9, dammod={str=1.2} },

	resists = { [DamageType.COLD] = 20 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {unique=true, not_properties={"lore"}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_STUN]={base=1, every=6, max=6},
	},

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(1, "infusion"),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-thaloren", engine.Quest.COMPLETED, "norgos")
	end,
}
