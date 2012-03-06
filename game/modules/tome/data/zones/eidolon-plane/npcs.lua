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

newEntity{ define_as = "EIDOLON",
	type = "unknown", subtype = "unknown",
	name = "The Eidolon",
	display = "@", color=colors.GREY,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/unknown_unknown_the_eidolon.png", display_h=2, display_y=-1}}},
	desc = [[Void seems more... alive, this creature stares at you with interrest.]],
	faction = "neutral",
	blood_color = colors.DARK,
	level_range = {200, nil}, exp_worth = 0,
	rank = 5,
	never_move = 1,
	invulnerable = 1,
	never_anger = 1,

	can_talk = "eidolon-plane",
}
