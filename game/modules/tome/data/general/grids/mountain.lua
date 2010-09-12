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
	define_as = "ROCKY_GROUND",
	name = "rocky ground", image = "terrain/rocky_ground.png",
	display = '.', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
}

newEntity{
	define_as = "MOUNTAIN_WALL",
	name = "rocky mountain", image = "terrain/rocky_mountain.png",
	display = '#', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -20,
	dig = "ROCKY_GROUND",
}

newEntity{
	define_as = "ROCKY_SNOWY_TREE",
	name = "rocky mountain", image = "terrain/rocky_snowy_tree.png",
	display = '#', color=colors.WHITE, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "ROCKY_GROUND",
}

newEntity{
	define_as = "HARDMOUNTAIN_WALL",
	name = "hard rocky mountain", image = "terrain/rocky_mountain.png",
	display = '#', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	air_level = -20,
}
