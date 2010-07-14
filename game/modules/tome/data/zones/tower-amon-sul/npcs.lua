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

load("/data/general/npcs/rodent.lua")
load("/data/general/npcs/vermin.lua")
load("/data/general/npcs/molds.lua")
load("/data/general/npcs/skeleton.lua")
load("/data/general/npcs/snake.lua")

local Talents = require("engine.interface.ActorTalents")

-- The boss of Amon Sul, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "SHADE_OF_ANGMAR",
	type = "undead", subtype = "skeleton", unique = true,
	name = "The Shade of Angmar",
	display = "s", color=colors.VIOLET,
	shader = "unique_glow",
	desc = [[This skeleton looks nasty. There is red flames in its empty eye sockets. It wield a nasty sword and towers toward you, throwing spells.]],
	level_range = {7, 20}, exp_worth = 2,
	max_life = 150, life_rating = 15, fixed_rating = true,
	max_mana = 85,
	max_stamina = 85,
	rank = 4,
	size_category = 3,
	infravision = 20,
	stats = { str=16, dex=12, cun=14, mag=25, con=16 },
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{ {type="weapon", subtype="staff", defined="STAFF_ANGMAR", autoreq=true}, {type="armor", subtype="light", autoreq=true}, },
	drops = resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_MANA_POOL]=1, [Talents.T_MANATHRUST]=4, [Talents.T_FREEZE]=4, [Talents.T_TIDAL_WAVE]=2,
		[Talents.T_STAMINA_POOL]=1, [Talents.T_SWORD_MASTERY]=3, [Talents.T_STUNNING_BLOW]=1,
	},

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=4, ai_move="move_astar" },

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-dunadan", engine.Quest.COMPLETED, "amon-sul")
	end,
}
