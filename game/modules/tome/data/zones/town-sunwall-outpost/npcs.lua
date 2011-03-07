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

load("/data/general/npcs/sunwall-town.lua", rarity(0))
load("/data/general/npcs/.lua", function(e) e.faction = "sunwall" end)

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "SUN_PALADIN_TORNUK",
	type = "humanoid", subtype = "human",
	display = "p",
	faction = "sunwall",
	name = "Sun Paladin Tornuk", color=colors.VIOLET, unique = true,
	desc = [[A beautiful woman, clad in shining plate armour. Power radiates from her.]],
	level_range = {7, nil}, exp_worth = 2,
	rank = 4,
	size_category = 3,
	female = true,
	max_life = 150, life_rating = 14, fixed_rating = true,
	infravision = 20,
	stats = { str=15, dex=10, cun=12, mag=16, con=14 },
	instakill_immune = 1,
	move_others=true,

	open_door = true,

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_astar", },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.equip{
		{type="weapon", subtype="mace", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="massive", autoreq=true},
		{type="jewelry", subtype="ring", defined="RING_FLAMES", autoreq=true},
	},
	resolvers.talents{
		[Talents.T_MASSIVE_ARMOUR_TRAINING]=1,
		[Talents.T_CHANT_OF_FORTITUDE]=2,
		[Talents.T_SEARING_LIGHT]=3,
		[Talents.T_MARTYRDOM]=3,
		[Talents.T_BARRIER]=3,
		[Talents.T_WEAPON_OF_LIGHT]=2,
	},
	resolvers.sustains_at_birth(),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-orc", engine.Quest.COMPLETED, "sunwall-outpost")
	end,
}
