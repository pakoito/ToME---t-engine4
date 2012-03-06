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

local slime_wall_editer = {method="walls_def", def="slime_wall"}

newEntity{
	define_as = "SLIME_FLOOR",
	type = "floor", subtype = "slime",
	name = "slime floor", image = "terrain/slime/slime_floor_01.png",
	display = '.', color=colors.LIGHT_GREEN, back_color=colors.GREEN,
	grow = "SLIME_WALL",
	nice_tiler = { method="replace", base={"SLIME_FLOOR", 100, 1, 5} },
}
for i = 1, 5 do newEntity{ base="SLIME_FLOOR", define_as = "SLIME_FLOOR"..i, image = "terrain/slime/slime_floor_0"..i..".png"} end

newEntity{
	define_as = "SLIME_WALL",
	type = "wall", subtype = "slime",
	name = "slime wall", image = "terrain/slime/slime_wall_V2_5_01.png",
	display = '#', color=colors.LIGHT_GREEN, back_color=colors.GREEN,
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -20,
	dig = "SLIME_FLOOR",
	nice_editer = slime_wall_editer,
	nice_tiler = { method="replace", base={"SLIME_WALL", 100, 1, 5} },
}
for i = 1, 5 do newEntity{ base="SLIME_WALL", define_as = "SLIME_WALL"..i, image = "terrain/slime/slime_wall_V2_5_0"..i..".png"} end


-----------------------------------------
-- Level changers
-----------------------------------------
newEntity{
	define_as = "SLIME_UP", image = "terrain/slime/slime_floor_01.png", add_mos = {{image="terrain/slime/slime_stairs_up_left_01.png"}},
	type = "floor", subtype = "slime",
	name = "previous level",
	display = '<', color=colors.LIGHT_GREEN, back_color=colors.GREEN,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "SLIME_DOWN", image = "tterrain/slime/slime_floor_01.png", add_mos = {{image="terrain/slime/slime_stair_down_01.png"}},
	type = "floor", subtype = "slime",
	name = "next level",
	display = '>', color=colors.LIGHT_GREEN, back_color=colors.GREEN,
	notice = true,
	always_remember = true,
	change_level = 1,
}

-----------------------------------------
-- Doors
-----------------------------------------
newEntity{
	define_as = "SLIME_DOOR",
	type = "wall", subtype = "slime",
	name = "slime door",
	display = '+', color=colors.LIGHT_GREEN, back_color=colors.GREEN,
	nice_tiler = { method="door3d", north_south="SLIME_DOOR_VERT", west_east="SLIME_DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
--	nice_editer = slime_wall_editer,
	is_door = true,
	door_opened = "SLIME_DOOR_OPEN",
	dig = "FLOOR",
}
newEntity{
	define_as = "SLIME_DOOR_OPEN",
	type = "wall", subtype = "slime",
	name = "open slime door",
	display = "'", color=colors.LIGHT_GREEN, back_color=colors.GREEN,
	always_remember = true,
--	nice_editer = slime_wall_editer,
	is_door = true,
	door_closed = "SLIME_DOOR",
}
newEntity{ base = "SLIME_DOOR", define_as = "SLIME_DOOR_HORIZ", image = "terrain/slime/slime_floor_01.png", add_displays={class.new{image="terrain/slime/slime_door_hor_closed_lower_01.png", add_mos={{image="terrain/slime/slime_door_hor_open_upper_01.png", display_y=-1}, {image="terrain/slime/floor_wall_slime_doorways_01.png"}}}}, door_opened = "SLIME_DOOR_HORIZ_OPEN"}
newEntity{ base = "SLIME_DOOR_OPEN", define_as = "SLIME_DOOR_HORIZ_OPEN", image = "terrain/slime/slime_floor_01.png", add_displays={class.new{image="terrain/slime/slime_door_hor_open_lower_01.png", add_mos={{image="terrain/slime/slime_door_hor_open_upper_01.png", display_y=-1}}}}, door_closed = "SLIME_DOOR_HORIZ"}

newEntity{ base = "SLIME_DOOR", define_as = "SLIME_DOOR_VERT", image = "terrain/slime/slime_floor_01.png", add_mos={{image="terrain/slime/slime_door_ver_top_closed_01.png", display_y=-1}}, add_displays={class.new{z=17, image="terrain/slime/slime_door_ver_bottom_closed_01.png", add_mos={{image="terrain/slime/slime_wall_V2_top_01.png"}, {image="terrain/slime/slime_edge_ver_door_left_01.png", display_x=-1}, {image="terrain/slime/slime_edge_ver_door_right_01.png", display_x=1}}}}, door_opened = "SLIME_DOOR_OPEN_VERT", dig = "SLIME_DOOR_OPEN_VERT"}
newEntity{ base = "SLIME_DOOR_OPEN", define_as = "SLIME_DOOR_OPEN_VERT", image = "terrain/slime/slime_floor_01.png", add_mos={{image="terrain/slime/slime_door_ver_top_lower_part_01.png"}}, add_displays={class.new{z=17, image="terrain/slime/slime_door_ver_bottom_open_01.png", add_mos={{image="terrain/slime/slime_wall_V2_top_01.png"}, {image="terrain/slime/slime_edge_ver_door_left_01.png", display_x=-1}, {image="terrain/slime/slime_edge_ver_door_right_01.png", display_x=1}, {image="terrain/slime/slime_door_ver_top_upper_part_01.png", display_y=-1}}}}, door_closed = "SLIME_DOOR_VERT"}
