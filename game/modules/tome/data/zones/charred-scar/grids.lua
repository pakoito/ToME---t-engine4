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

load("/data/general/grids/basic.lua")

newEntity{
	define_as = "LAVA_FLOOR",
	name = "lava floor", image = "terrain/lava_floor.png",
	display = '.', color=colors.RED, back_color=colors.DARK_GREY,
	shader = "lava",
}

newEntity{
	define_as = "LAVA_WALL",
	name = "lava wall", image = "terrain/granite_wall1.png",
	display = '#', color=colors.RED, back_color=colors.DARK_GREY, tint=colors.LIGHT_RED,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	air_level = -20,
}

newEntity{
	define_as = "LAVA",
	name = "molten lava", image = "terrain/lava.png",
	display = '%', color=colors.LIGHT_RED, back_color=colors.RED,
	does_block_move = true,
	shader = "lava",
}

newEntity{
	define_as = "FAR_EAST_PORTAL",
	name = "Farportal: the Far East",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[A farportal is a way to travel incredible distances in the blink of an eye. They usually require an external item to use.]],

	orb_portal = {
		change_level = 1,
		change_zone = "wilderness-arda-fareast",
		change_wilderness = {
			x = 9, y = 5,
		},
		message = "#VIOLET#You enter the swirling portal and in the blink of an eye you are back to the far east.",
	},
}
