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

-- last updated:  10:46 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SHERTUL",
	type = "horror", subtype = "sher'tul",
	display = "h", color=colors.WHITE,
	blood_color = colors.BLUE,
	body = { INVEN = 10 },
	autolevel = "caster",
	ai = "tactical", ai_state = { ai_move="move_dmap",  },

	stats = { str=40, dex=40, wil=40, con=40, mag=40, cun=40, lck=100 },
	combat_armor = 0, combat_def = 0,
	combat = { dam=5, atk=15, apr=7, dammod={str=0.6} },
	infravision = 10,
	max_life = resolvers.rngavg(500,600),
	rank = 3,
	size_category = 3,

	no_breath = 1,
	fear_immune = 1,
}
