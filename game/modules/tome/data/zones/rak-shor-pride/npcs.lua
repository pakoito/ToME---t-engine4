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

load("/data/general/npcs/ghoul.lua", function(e) if e.rarity then e.rarity = e.rarity * 3 end end)
load("/data/general/npcs/skeleton.lua", function(e) if e.rarity then e.rarity = e.rarity * 3 end end)
load("/data/general/npcs/orc.lua", function(e) if e.rarity then e.rarity = e.rarity * 3 end end)
load("/data/general/npcs/orc-rak-shor.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_ORC_RAK_SHOR", define_as = "RAK_SHOR",
	name = "Rak'shor, Grand Necromancer of the Pride", color=colors.VIOLET, unique = true,
	desc = [[An old orc, wearing black robes. He commands his undead armies to destroy you.]],
	level_range = {35, 50}, exp_worth = 2,
	rank = 4,
	max_life = 150, life_rating = 16, fixed_rating = true,
	infravision = 20,
	stats = { str=15, dex=10, cun=12, mag=16, con=14 },
	move_others=true,

	combat_armor = 10, combat_def = 10,

	open_door = true,

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_astar", },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	resolvers.equip{
		{type="weapon", subtype="staff", ego_change=100, autoreq=true},
		{type="armor", subtype="cloth", ego_change=100, autoreq=true},
	},

	summon = {
		{type="undead", subtype="skeleton", number=3, hasxp=false},
		{type="humanoid", subtype="ghoul", number=3, hasxp=false},
	},
	make_escort = {
		{type="undead", subtype="ghoul", no_subescort=true, number=resolvers.mbonus(4, 4)},
		{type="undead", subtype="skeleton", no_subescort=true, number=resolvers.mbonus(4, 4)},
	},

	resolvers.talents{
--		[Talents.T_]=2,
	},

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("orc-pride", engine.Quest.COMPLETED, "rak-shor")
	end,
}
