-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	no_prob_travel = true,
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
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/lava_floor.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[A farportal is a way to travel incredible distances in the blink of an eye. They usually require an external item to use.]],

	orb_portal = {
		change_level = 1,
		change_zone = "wilderness",
		change_wilderness = {
			spot = {type="farportal-end", subtype="fareast"},
		},
		message = "#VIOLET#You enter the swirling portal and in the blink of an eye you are back to the far east.",
	},
}

newEntity{ base = "FAR_EAST_PORTAL", define_as = "CFAR_EAST_PORTAL",
	image = "terrain/lava_floor.png",
	add_displays = {class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3}},
	on_added = function(self, level, x, y)
		level.map:particleEmitter(x, y, 3, "farportal_vortex")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(y, y, 3, "farportal_lightning")
	end,
}
