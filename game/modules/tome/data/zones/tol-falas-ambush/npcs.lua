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

load("/data/general/npcs/orc.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_ORC", define_as = "UKRUK",
	unique = true,
	name = "Ukruk the Fierce",
	color=colors.VIOLET,
	desc = [[This ugly orc looks really nasty and vicious. He is obviously looking for something and bears an unkown symbol on his shield.]],
	level_range = {50, 50}, exp_worth = 2,
	max_life = 15000, life_rating = 15, fixed_rating = true,
	rank = 4,
	size_category = 3,

	resolvers.equip{
		{type="weapon", subtype="longsword", ego_chance=100, autoreq=true},
		{type="armor", subtype="shield", ego_chance=100, autoreq=true},
	},

	resolvers.talents{
		[Talents.T_SWORD_MASTERY]=10, [Talents.T_ASSAULT]=5, [Talents.T_OVERPOWER]=5,
	},
	combat_atk = 1000,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
}
