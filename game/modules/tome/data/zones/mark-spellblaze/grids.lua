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

load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/lava.lua")

for i = 1, 20 do
newEntity{
	define_as = "BURNT_TREE"..i,
	name = "burnt tree",
	image = "terrain/grass_burnt1.png",
	add_displays = class:makeTrees("terrain/burnttree_alpha"),
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "GRASS",
}
end

for i = 1, 4 do
newEntity{ define_as = "BURNT_GROUND"..i,
	name='burnt ground',
	display='.', color=colors.UMBER, back_color=colors.DARK_GREY, image="terrain/grass_burnt"..i..".png",
}
end

newEntity{
	define_as = "ALTAR",
	name = "corrupted alter", image = "terrain/floor_pentagram.png",
	display = ';', color=colors.RED, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
}
