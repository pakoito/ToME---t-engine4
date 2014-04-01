-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

local snowy_grass_editer = { method="borders_def", def="snowy_grass"}

newEntity{
	define_as = "SNOWY_GRASS",
	type = "floor", subtype = "snowy_grass",
	name = "snowy grass", image = "terrain/grass/snowy_grass_main_01.png",
	display = '.', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	grow = "SNOWY_TREE",
	nice_tiler = { method="replace", base={"SNOWY_PATCH", 100, 1, 14}},
	nice_editer = snowy_editer,
}
for i = 1, 14 do newEntity{ base = "SNOWY_GRASS", define_as = "SNOWY_PATCH"..i, image = ("terrain/grass/snowy_grass_main_%02d.png"):format(i) } end

local snowy_treesdef = {
	{"small_elm", {"shadow", "trunk", "foliage_winter"}},
	{"elm", {tall=-1, "shadow", "trunk", "foliage_winter"}},
}

newEntity{
	define_as = "SNOWY_TREE",
	type = "wall", subtype = "snowy_grass",
	name = "winter tree",
	image = "terrain/snowy_tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "snowy",
	nice_tiler = { method="replace", base={"SNOWY_TREE", 100, 1, 30}},
	nice_editer = snowy_editer,
}
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="SNOWY_TREE", define_as = "SNOWY_TREE"..i, image = "terrain/grass/snowy_grass_main_01.png"}, snowy_treesdef))
end

newEntity{
	define_as = "HARDSNOWY_TREE",
	type = "wall", subtype = "snowy_grass",
	name = "tall thick tree",
	image = "terrain/snowy_tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	nice_tiler = { method="replace", base={"HARDSNOWY_TREE", 100, 1, 30}},
	nice_editer = snowy_editer,
}
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="HARDSNOWY_TREE", define_as = "HARDSNOWY_TREE"..i, image = "terrain/grass/snowy_grass_main_01.png"}, snowy_treesdef))
end

-----------------------------------------
-- Forest road
-----------------------------------------
newEntity{
	define_as = "snowy_ROAD_STONE",
	type = "floor", subtype = "snowy_grass", road="oldstone",
	name = "old road", image = "terrain/grass/snowy_grass_main_01.png",
	display = '=', color=colors.DARK_GREY,
	always_remember = true,
	nice_editer = snowy_editer,
	nice_editer2 = { method="roads_def", def="oldstone" },
}
newEntity{
	define_as = "snowy_ROAD_DIRT",
	type = "floor", subtype = "snowy_grass", road="dirt",
	name = "old road", image = "terrain/grass/snowy_grass_main_01.png",
	display = '=', color=colors.DARK_GREY,
	always_remember = true,
	nice_editer = snowy_editer,
	nice_editer2 = { method="roads_def", def="dirt" },
}

-----------------------------------------
-- snowyy exits
-----------------------------------------
newEntity{
	define_as = "snowy_UP_WILDERNESS",
	type = "floor", subtype = "snowy_grass",
	name = "exit to the worldmap", image = "terrain/grass/snowy_grass_main_01.png", add_mos = {{image="terrain/worldmap.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
	nice_editer = snowy_editer,
}

newEntity{
	define_as = "snowy_UP8",
	type = "floor", subtype = "snowy_grass",
	name = "way to the previous level", image = "terrain/grass/snowy_grass_main_01.png", add_mos = {{image="terrain/way_next_8.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = snowy_editer,
}
newEntity{
	define_as = "snowy_UP2",
	type = "floor", subtype = "snowy_grass",
	name = "way to the previous level", image = "terrain/grass/snowy_grass_main_01.png", add_mos = {{image="terrain/way_next_2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = snowy_editer,
}
newEntity{
	define_as = "snowy_UP4",
	type = "floor", subtype = "snowy_grass",
	name = "way to the previous level", image = "terrain/grass/snowy_grass_main_01.png", add_mos = {{image="terrain/way_next_4.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = snowy_editer,
}
newEntity{
	define_as = "snowy_UP6",
	type = "floor", subtype = "snowy_grass",
	name = "way to the previous level", image = "terrain/grass/snowy_grass_main_01.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = snowy_editer,
}

newEntity{
	define_as = "snowy_DOWN8",
	type = "floor", subtype = "snowy_grass",
	name = "way to the next level", image = "terrain/grass/snowy_grass_main_01.png", add_mos = {{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = snowy_editer,
}
newEntity{
	define_as = "snowy_DOWN2",
	type = "floor", subtype = "snowy_grass",
	name = "way to the next level", image = "terrain/grass/snowy_grass_main_01.png", add_mos = {{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = snowy_editer,
}
newEntity{
	define_as = "snowy_DOWN4",
	type = "floor", subtype = "snowy_grass",
	name = "way to the next level", image = "terrain/grass/snowy_grass_main_01.png", add_mos = {{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = snowy_editer,
}
newEntity{
	define_as = "snowy_DOWN6",
	type = "floor", subtype = "snowy_grass",
	name = "way to the next level", image = "terrain/grass/snowy_grass_main_01.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = snowy_editer,
}
