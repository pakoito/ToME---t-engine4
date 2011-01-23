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

load("/data/general/npcs/ritch.lua", rarity(0))
load("/data/general/npcs/vermin.lua", rarity(0))
load("/data/general/npcs/ant.lua", rarity(2))
load("/data/general/npcs/jelly.lua", rarity(3))

local Talents = require("engine.interface.ActorTalents")



newEntity{ base = "BASE_NPC_RITCH_REL", define_as = "HIVE_MOTHER",
	type = "humanoid", subtype="atch", unique = true,
	name = "Murgol",
	display = "y", color=colors.VIOLET,
	desc = [[This monstrous yeek depravity opposes all that the Way stands for. The Way commands that he is eliminated.]],
	level_range = {7, nil}, exp_worth = 2,
	max_life = 190, life_rating = 17, fixed_rating = true,
	infravision = 20,
	stats = { str=15, dex=10, cun=8, mag=16, wil=10, con=15 },
	move_others=true,

	instakill_immune = 1,
	rank = 4,
	size_category = 4,
	no_breath = 1,

	combat = { dam=30, atk=22, apr=7, dammod={str=1.1} },

	body = { INVEN = 10, BODY=1 },

	resolvers.drops{chance=100, nb=1, {defined="FLAMEWROUGHT", random_art_replace={chance=75}}, },
	resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	resolvers.talents{
	},
	resolvers.sustains_at_birth(),

	summon = {
		{type="insect", subtype="ritch", number=1, hasxp=false},
	},

	autolevel = "dexmage",
	ai = "tactical", ai_state = { talent_in=2, },

	on_die = function(self, who)
		game.player:setQuestStatus("start-yeek", engine.Quest.COMPLETED, "murgol")
	end,
}
