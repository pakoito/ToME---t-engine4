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

load("/data/general/npcs/rodent.lua", rarity(0))
load("/data/general/npcs/vermin.lua", rarity(2))
load("/data/general/npcs/molds.lua", rarity(1))
load("/data/general/npcs/skeleton.lua", rarity(0))
load("/data/general/npcs/snake.lua", rarity(2))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "NECROMANCER",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.DARK_GREY,
	name = "Necromancer", color=colors.DARK_GREY,
	desc = [[An human dressed in black robes. He mumbles is a harsh tongue. He seems to think you are his slave.]],
	level_range = {1, nil}, exp_worth = 1,

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, CLOAK=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 20,
	lite = 2,

	rank = 2,
	size_category = 2,

	open_door = true,

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	energy = { mod=1 },
	stats = { str=10, dex=8, mag=16, con=6 },

	max_life = resolvers.rngavg(70,80), life_rating = 7,
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloak", defined="CLOAK_DECEPTION", autoreq=true},
	},

	resolvers.talents{
		[Talents.T_SOUL_ROT]=1,
	},

	die = function(self, src)
		self.die = function() end
		local Chat = require "engine.Chat"
		local chat = Chat.new("undead-start-kill", self, game.player)
		chat:invoke()
	end,
}
