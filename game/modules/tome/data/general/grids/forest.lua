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
	define_as = "GRASS",
	name = "grass", image = "terrain/grass.png",
	display = '.', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
}

for i = 1, 20 do
newEntity{
	define_as = "TREE"..(i > 1 and i or ""),
	name = "tree",
	image = "terrain/grass.png",
	add_displays = class:makeTrees("terrain/tree_alpha"),
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "GRASS",
}
end

newEntity{
	define_as = "GRASS_DARK1",
	name = "grass", image = "terrain/grass_dark1.png",
	display = '.', color=colors.GREEN, back_color={r=44,g=95,b=43},
}

for i = 1, 20 do
newEntity{
	define_as = "TREE_DARK"..i,
	name = "tree", image = "terrain/grass_dark1.png",
	force_clone = true,
	add_displays = class:makeTrees("terrain/tree_alpha"),
	display = '#', color=colors.GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "GRASS_DARK1",
}
end

newEntity{
	define_as = "FLOWER",
	name = "flower", image = "terrain/grass_flower3.png",
	display = ';', color=colors.YELLOW, back_color={r=44,g=95,b=43},
}
