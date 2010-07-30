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
	define_as = "UNDERGROUND_FLOOR",
	name = "floor", image = "terrain/underground_floor.png",
	display = '.', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
}

for i = 1, 20 do
newEntity{
	define_as = "UNDERGROUND_TREE"..(i > 1 and i or ""),
	name = "tree",
	image = "terrain/underground_floor.png",
	add_displays = class:makeTrees("terrain/underground_tree_alpha", 7),
	display = '#', color=colors.PURPLE, back_color=colors.UMBER,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "UNDERGROUND_FLOOR",
}
end
