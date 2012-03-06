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

--load("/data/general/npcs/rodent.lua", rarity(5))
--load("/data/general/npcs/vermin.lua", rarity(2))
--load("/data/general/npcs/snake.lua", rarity(3))
--load("/data/general/npcs/bear.lua", rarity(2))
--load("/data/general/npcs/crystal.lua", rarity(10))
load("/data/general/npcs/losgoroth.lua", rarity(1))

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_LOSGOROTH", define_as = "SPACIAL_DISTURBANCE",
	unique = true,
	name = "Spacial Disturbance",
	color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png"},
	resolvers.generic(function(e) if engine.Map.tiles.nicer_tiles then e:addParticles(engine.Particles.new("wormhole", 1, {image="shockbolt/npc/elemental_losgoroth_space_disturbance", speed=1})) end end),
	desc = [[A hole in the fabric of space, it seems to be the source of the expanse unstability.]],
	killer_message = "and folded out of existence",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 10, fixed_rating = true,
	mana_regen = 7,
	stats = { str=10, dex=10, cun=12, mag=20, con=10 },
	rank = 4,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,
	can_pass = {pass_void=0},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="VOID_STAR"} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_VOID_BLAST]={base=1, every=7, max=7},
		[Talents.T_MANATHRUST]={base=1, every=7, max=7},
		[Talents.T_PHASE_DOOR]=2,
	},
	resolvers.inscriptions(1, {"manasurge rune"}),

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	on_die = function(self, who)
		local q = game.player:hasQuest("start-archmage")
		if q then q:stabilized() end
		game.player:resolveSource():setQuestStatus("start-archmage", engine.Quest.COMPLETED, "abashed")
	end,
}
