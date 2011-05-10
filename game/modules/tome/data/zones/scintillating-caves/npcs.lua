-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
load("/data/general/npcs/vermin.lua", rarity(2))
load("/data/general/npcs/snake.lua", rarity(3))
load("/data/general/npcs/bear.lua", rarity(2))
load("/data/general/npcs/crystal.lua", rarity(1))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_CRYSTAL", define_as = "SPELLBLAZE_CRYSTAL",
	allow_infinite_dungeon = true,
	unique = true,
	name = "Spellblaze Crystal", tint=colors.PURPLE, image = "npc/spellblaze_crystal.png",
	color=colors.VIOLET,
	desc = [[A formation of purple crystal. It seems strangely aware.]],
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 12, fixed_rating = true,
	mana_regen = 3,
	stats = { str=10, dex=10, cun=12, mag=20, con=10 },
	rank = 4,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="CRYSTAL_FOCUS", random_art_replace={chance=75}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_FLAME]=1,
		[Talents.T_ICE_SHARDS]=1,
		[Talents.T_SOUL_ROT]=1,
		[Talents.T_ELEMENTAL_BOLT]=1,
	},
	resolvers.inscriptions(1, {"manasurge rune"}),
	inc_damage = { all = -35 },

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-shaloren", engine.Quest.COMPLETED, "spellblaze")
	end,
}
