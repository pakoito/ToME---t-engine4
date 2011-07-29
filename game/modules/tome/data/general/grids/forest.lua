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

local grass_editer = { method="borders_def", def="grass"}

newEntity{
	define_as = "GRASS",
	type = "floor", subtype = "grass",
	name = "grass", image = "terrain/grass.png",
	display = '.', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	grow = "TREE",
	nice_tiler = { method="replace", base={"GRASS_PATCH", 70, 1, 12}},
	nice_editer = grass_editer,
}
for i = 1, 12 do newEntity{ base = "GRASS", define_as = "GRASS_PATCH"..i, image = "terrain/grass"..(i<7 and "" or "2")..".png" } end

newEntity{
	define_as = "TREE",
	type = "wall", subtype = "grass",
	name = "tree",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "GRASS",
	nice_tiler = { method="replace", base={"TREE", 100, 1, 30}},
	nice_editer = grass_editer,
}
for i = 1, 30 do newEntity{ base="TREE", define_as = "TREE"..i, image = "terrain/grass.png", add_displays = class:makeTrees("terrain/tree_alpha", 13, 9)} end

newEntity{
	define_as = "HARDTREE",
	type = "wall", subtype = "grass",
	name = "tall thick tree",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	nice_tiler = { method="replace", base={"HARDTREE", 100, 1, 30}},
	nice_editer = grass_editer,
}
for i = 1, 30 do newEntity{ base="HARDTREE", define_as = "HARDTREE"..i, image = "terrain/grass.png", add_displays = class:makeTrees("terrain/tree_alpha", 13, 9) } end

newEntity{
	define_as = "FLOWER",
	type = "floor", subtype = "grass",
	name = "flower", image = "terrain/flower.png",
	display = ';', color=colors.YELLOW, back_color={r=44,g=95,b=43},
	grow = "TREE",
	nice_tiler = { method="replace", base={"FLOWER", 100, 1, 6+7}},
	nice_editer = grass_editer,
}
for i = 1, 6+7 do newEntity{ base = "FLOWER", define_as = "FLOWER"..i, image = "terrain/grass.png", add_mos = {{image = "terrain/"..(i<=6 and "flower_0"..i..".png" or "mushroom_0"..(i-6)..".png")}}} end

newEntity{
	define_as = "ROCK_VAULT",
	type = "wall", subtype = "grass",
	name = "huge loose rock", image = "terrain/grass.png", add_mos = {{image="terrain/huge_rock.png"}},
	display = '+', color=colors.GREY, back_color={r=44,g=95,b=43},
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	door_player_check = "This rock is loose, you think you can move it away.",
	door_opened = "GRASS",
	dig = "GRASS",
	nice_editer = grass_editer,
}

-----------------------------------------
-- Grassy exits
-----------------------------------------
newEntity{
	define_as = "GRASS_UP_WILDERNESS",
	type = "floor", subtype = "grass",
	name = "exit to the worldmap", image = "terrain/grass.png", add_mos = {{image="terrain/worldmap.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
	nice_editer = grass_editer,
}

newEntity{
	define_as = "GRASS_UP8",
	type = "floor", subtype = "grass",
	name = "way to the previous level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_8.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "GRASS_UP2",
	type = "floor", subtype = "grass",
	name = "way to the previous level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "GRASS_UP4",
	type = "floor", subtype = "grass",
	name = "way to the previous level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_4.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "GRASS_UP6",
	type = "floor", subtype = "grass",
	name = "way to the previous level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = grass_editer,
}

newEntity{
	define_as = "GRASS_DOWN8",
	type = "floor", subtype = "grass",
	name = "way to the next level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "GRASS_DOWN2",
	type = "floor", subtype = "grass",
	name = "way to the next level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "GRASS_DOWN4",
	type = "floor", subtype = "grass",
	name = "way to the next level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "GRASS_DOWN6",
	type = "floor", subtype = "grass",
	name = "way to the next level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = grass_editer,
}
