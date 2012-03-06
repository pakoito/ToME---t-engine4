-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

for i = 1, 20 do
newEntity{
	define_as = "BURNT_TREE"..i,
	type = "wall", subtype = "burnt",
	name = "burnt tree",
	image = "terrain/grass_burnt1.png",
	add_displays = class:makeTrees("terrain/burnttree_alpha", 8, 0),
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "BURNT_GROUND1",
}
end

newEntity{ define_as = "BURNT_GROUND",
	type = "floor", subtype = "burnt",
	name='burnt ground',
	display='.', color=colors.UMBER, back_color=colors.DARK_GREY, image="terrain/grass_burnt1.png",
	nice_tiler = { method="replace", base={"BURNT_GROUND", 15, 1, 7}},
}
for i = 1, 7 do newEntity{ base="BURNT_GROUND", define_as = "BURNT_GROUND"..i, add_mos={{image="terrain/burnt_floor_deco"..i..".png"}}} end

newEntity{
	define_as = "ALTAR",
	type = "floor", subtype = "burnt",
	name = "corrupted altar", image = "terrain/grass_burnt1.png", add_displays = {class.new{image = "terrain/floor_pentagram.png"}},
	display = ';', color=colors.RED, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
}

newEntity{
	define_as = "BURNT_UP_WILDERNESS",
	type = "floor", subtype = "burnt",
	name = "exit to the worldmap", image = "terrain/grass_burnt1.png", add_displays = {class.new{image="terrain/worldmap.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}
newEntity{
	define_as = "BURNT_UP4",
	type = "floor", subtype = "burnt",
	name = "way to the previous level", image = "terrain/grass_burnt1.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "BURNT_DOWN6",
	type = "floor", subtype = "burnt",
	name = "way to the next level", image = "terrain/grass_burnt1.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
