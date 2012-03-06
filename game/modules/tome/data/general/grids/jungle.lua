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

local grass_editer = { method="borders_def", def="jungle_grass"}

newEntity{
	define_as = "JUNGLE_GRASS",
	type = "floor", subtype = "grass",
	name = "grass", image = "terrain/jungle/jungle_grass_floor_01.png",
	display = '.', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	grow = "JUNGLE_TREE",
	nice_tiler = { method="replace", base={"JUNGLE_GRASS_PATCH", 60, 1, 5+8+3+4+4}},
	nice_editer = grass_editer,
}
for i = 1, 5 do
	newEntity{ base = "JUNGLE_GRASS", define_as = "JUNGLE_GRASS_PATCH"..i, add_displays={class.new{z=3,image = "terrain/jungle/jungle_brush_"..({2,3,4,6,8})[i].."_64_01.png"}} }
end
for i = 1, 8 do
	newEntity{ base = "JUNGLE_GRASS", define_as = "JUNGLE_GRASS_PATCH"..(i+5), add_displays={class.new{z=3,image = "terrain/jungle/jungle_brush_"..({4,5,6,7,8,9,10,11})[i].."_128_01.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2}} }
end
for i = 1, 3 do
	newEntity{ base = "JUNGLE_GRASS", define_as = "JUNGLE_GRASS_PATCH"..(i+5+8), add_displays={class.new{z=3,image = "terrain/jungle/jungle_brush_"..({3,4,5})[i].."_192_01.png", display_x=-1, display_y=-1, display_w=3, display_h=3}} }
end
for i = 1, 4 do
	newEntity{ base = "JUNGLE_GRASS", define_as = "JUNGLE_GRASS_PATCH"..(i+5+8+3), add_displays={class.new{z=3,image = "terrain/jungle/jungle_dirt_var_"..i.."_64_01.png"}} }
end
for i = 1, 4 do
	newEntity{ base = "JUNGLE_GRASS", define_as = "JUNGLE_GRASS_PATCH"..(i+5+8+3+4), add_displays={class.new{z=3,image = "terrain/jungle/jungle_plant_0"..i..".png"}} }
end

newEntity{
	define_as = "JUNGLE_DIRT",
	type = "floor", subtype = "mud",
	name = "muddy floor", image = "terrain/jungle/jungle_dirt_floor_01.png",
	display = '.', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
}

newEntity{
	define_as = "JUNGLE_TREE",
	type = "wall", subtype = "grass",
	name = "tree",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "JUNGLE_GRASS",
	nice_tiler = { method="replace", base={"JUNGLE_TREE", 100, 1, 30}},
	nice_editer = grass_editer,
}
for i = 1, 30 do
	newEntity{ base="JUNGLE_TREE", define_as = "JUNGLE_TREE"..i, image = "terrain/jungle/jungle_grass_floor_01.png", add_displays = class:makeTrees("terrain/jungle/jungle_tree_", 17, 7)}
end

-----------------------------------------
-- Grassy exits
-----------------------------------------
newEntity{
	define_as = "JUNGLE_GRASS_UP_WILDERNESS",
	type = "floor", subtype = "grass",
	name = "exit to the worldmap", image = "terrain/jungle/jungle_grass_floor_01.png", add_mos = {{image="terrain/worldmap.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
	nice_editer = grass_editer,
}

newEntity{
	define_as = "JUNGLE_GRASS_UP8",
	type = "floor", subtype = "grass",
	name = "way to the previous level", image = "terrain/jungle/jungle_grass_floor_01.png", add_mos = {{image="terrain/way_next_8.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "JUNGLE_GRASS_UP2",
	type = "floor", subtype = "grass",
	name = "way to the previous level", image = "terrain/jungle/jungle_grass_floor_01.png", add_mos = {{image="terrain/way_next_2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "JUNGLE_GRASS_UP4",
	type = "floor", subtype = "grass",
	name = "way to the previous level", image = "terrain/jungle/jungle_grass_floor_01.png", add_mos = {{image="terrain/way_next_4.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "JUNGLE_GRASS_UP6",
	type = "floor", subtype = "grass",
	name = "way to the previous level", image = "terrain/jungle/jungle_grass_floor_01.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = grass_editer,
}

newEntity{
	define_as = "JUNGLE_GRASS_DOWN8",
	type = "floor", subtype = "grass",
	name = "way to the next level", image = "terrain/jungle/jungle_grass_floor_01.png", add_mos = {{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "JUNGLE_GRASS_DOWN2",
	type = "floor", subtype = "grass",
	name = "way to the next level", image = "terrain/jungle/jungle_grass_floor_01.png", add_mos = {{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "JUNGLE_GRASS_DOWN4",
	type = "floor", subtype = "grass",
	name = "way to the next level", image = "terrain/jungle/jungle_grass_floor_01.png", add_mos = {{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "JUNGLE_GRASS_DOWN6",
	type = "floor", subtype = "grass",
	name = "way to the next level", image = "terrain/jungle/jungle_grass_floor_01.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = grass_editer,
}
