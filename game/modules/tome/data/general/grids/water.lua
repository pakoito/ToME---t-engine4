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

newEntity{
	define_as = "WATER_FLOOR",
	name = "underwater", image = "terrain/water_floor.png",
	display = '.', color=colors.LIGHT_BLUE, back_color=colors.DARK_BLUE,
	air_level = -5, air_condition="water",
}

newEntity{
	define_as = "WATER_WALL",
	name = "wall", image = "terrain/water_wall.png",
	display = '#', color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -20,
}

newEntity{
	define_as = "SHALLOW_WATER",
	name = "shallow water", image = "terrain/water_floor.png",
	display = '~', color=colors.LIGHT_BLUE, back_color=colors.DARK_BLUE,
	shader = "water", textures = { function() return _3DNoise, true end },
	always_remember = true,
}

newEntity{
	define_as = "DEEP_WATER",
	name = "deep water", image = "terrain/water_floor.png",
	display = '~', color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	shader = "water", textures = { function() return _3DNoise, true end },
	always_remember = true,
	air_level = -5, air_condition="water",
}
