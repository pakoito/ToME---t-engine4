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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_MUMMY",
	type = "undead", subtype = "mummy",
	blood_color = colors.GREY,
	display = "Z", color=colors.WHITE,

	combat = { dam=1, atk=1, apr=1 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
	global_speed_base = 0.8,
	stats = { str=14, dex=12, mag=10, con=12 },
	infravision = 10,
	rank = 2,
	size_category = 3,

	resolvers.racial("shalore"),

	open_door = true,

	resolvers.inscriptions(1, "rune"),
	resolvers.tmasteries{ ["technique/2hweapon-offense"]=1, ["technique/2hweapon-cripple"]=1, },

	blind_immune = 1,
	see_invisible = 4,
	undead = 1,
	ingredient_on_death = "MUMMY_BONE",
	not_power_source = {nature=true},
}
