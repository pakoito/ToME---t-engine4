-- ToME - Tales of Maj'Eyal
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

for i = 1, 10 do
newEntity{
	define_as = "TREE"..i,
	name = "forest",
	image = "terrain/grass.png",
	add_displays = class:makeTrees("terrain/tree_alpha"),
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	does_block_move = true,
}
end

for i = 1, 10 do
newEntity{
	define_as = "TREE_DARK"..i,
	name = "old forest", image = "terrain/grass_dark1.png",
	force_clone = true,
	add_displays = class:makeTrees("terrain/tree_dark_alpha"),
	display = '#', color=colors.GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	does_block_move = true,
}
end
