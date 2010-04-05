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
	define_as = "QUICK_EXIT",
	name = "teleporting circle to the surface", image = "terrain/maze_teleport.png",
	display = '>', color_r=255, color_g=0, color_b=255,
	change_level = 1, change_zone = "wilderness",
}

newEntity{
	define_as = "MAZE_FLOOR",
	name = "floor", image = "terrain/maze_floor.png",
	display = '.', color_r=255, color_g=255, color_b=255,
}

newEntity{
	define_as = "MAZE_WALL",
	name = "wall", image = "terrain/granite_wall_lichen.png",
	display = '#', color_r=255, color_g=255, color_b=255,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	air_level = -20,
}
