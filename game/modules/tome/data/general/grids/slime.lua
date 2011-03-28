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

newEntity{
	define_as = "SLIME_FLOOR",
	name = "slimy floor", image = "terrain/slime_floor.png",
	display = '.', color=colors.LIGHT_GREEN, back_color=colors.GREEN,
	grow = "SLIME_WALL",
}

newEntity{
	define_as = "SLIME_WALL",
	name = "slimy wall", image = "terrain/slime_wall.png",
	display = '#', color=colors.LIGHT_GREEN, back_color=colors.GREEN,
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -20,
	dig = "FLOOR",
}
