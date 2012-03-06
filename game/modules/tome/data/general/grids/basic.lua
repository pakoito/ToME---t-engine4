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

-----------------------------------------
-- Dungeony exits
-----------------------------------------
newEntity{
	define_as = "UP_WILDERNESS",
	type = "floor", subtype = "floor",
	name = "exit to the worldmap", image = "terrain/marble_floor.png", add_mos = {{image="terrain/stair_up_wild.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "UP", image = "terrain/marble_floor.png", add_mos = {{image="terrain/stair_up.png"}},
	type = "floor", subtype = "floor",
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "DOWN", image = "terrain/marble_floor.png", add_mos = {{image="terrain/stair_down.png"}},
	type = "floor", subtype = "floor",
	name = "next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

-----------------------------------------
-- Outworld exits
-----------------------------------------
newEntity{
	define_as = "FLAT_UP_WILDERNESS",
	type = "floor", subtype = "floor",
	name = "exit to the worldmap", image = "terrain/marble_floor.png", add_mos = {{image="terrain/worldmap.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "FLAT_UP8",
	type = "floor", subtype = "floor",
	name = "way to the previous level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_8.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "FLAT_UP2",
	type = "floor", subtype = "floor",
	name = "way to the previous level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "FLAT_UP4",
	type = "floor", subtype = "floor",
	name = "way to the previous level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_4.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "FLAT_UP6",
	type = "floor", subtype = "floor",
	name = "way to the previous level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "FLAT_DOWN8",
	type = "floor", subtype = "floor",
	name = "way to the next level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "FLAT_DOWN2",
	type = "floor", subtype = "floor",
	name = "way to the next level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "FLAT_DOWN4",
	type = "floor", subtype = "floor",
	name = "way to the next level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "FLAT_DOWN6",
	type = "floor", subtype = "floor",
	name = "way to the next level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

-----------------------------------------
-- Basic floors
-----------------------------------------
newEntity{
	define_as = "FLOOR",
	type = "floor", subtype = "floor",
	name = "floor", image = "terrain/marble_floor.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
	grow = "WALL",
}

-----------------------------------------
-- Walls
-----------------------------------------
newEntity{
	define_as = "WALL",
	type = "wall", subtype = "floor",
	name = "wall", image = "terrain/granite_wall1.png",
	display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
	z = 3,
	nice_tiler = { method="wall3d", inner={"WALL", 100, 1, 5}, north={"WALL_NORTH", 100, 1, 5}, south={"WALL_SOUTH", 10, 1, 17}, north_south="WALL_NORTH_SOUTH", small_pillar="WALL_SMALL_PILLAR", pillar_2="WALL_PILLAR_2", pillar_8={"WALL_PILLAR_8", 100, 1, 5}, pillar_4="WALL_PILLAR_4", pillar_6="WALL_PILLAR_6" },
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -20,
	dig = "FLOOR",
}
for i = 1, 5 do
	newEntity{ base = "WALL", define_as = "WALL"..i, image = "terrain/granite_wall1_"..i..".png", z = 3}
	newEntity{ base = "WALL", define_as = "WALL_NORTH"..i, image = "terrain/granite_wall1_"..i..".png", z = 3, add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}}
	newEntity{ base = "WALL", define_as = "WALL_PILLAR_8"..i, image = "terrain/granite_wall1_"..i..".png", z = 3, add_displays = {class.new{image="terrain/granite_wall_pillar_8.png", z=18, display_y=-1}}}
end
newEntity{ base = "WALL", define_as = "WALL_NORTH_SOUTH", image = "terrain/granite_wall2.png", z = 3, add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}}
newEntity{ base = "WALL", define_as = "WALL_SOUTH", image = "terrain/granite_wall2.png", z = 3}
for i = 1, 17 do newEntity{ base = "WALL", define_as = "WALL_SOUTH"..i, image = "terrain/granite_wall2_"..i..".png", z = 3} end
newEntity{ base = "WALL", define_as = "WALL_SMALL_PILLAR", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_small.png",z=3}, class.new{image="terrain/granite_wall_pillar_small_top.png", z=18, display_y=-1}}}
newEntity{ base = "WALL", define_as = "WALL_PILLAR_6", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_3.png",z=3}, class.new{image="terrain/granite_wall_pillar_9.png", z=18, display_y=-1}}}
newEntity{ base = "WALL", define_as = "WALL_PILLAR_4", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_1.png",z=3}, class.new{image="terrain/granite_wall_pillar_7.png", z=18, display_y=-1}}}
newEntity{ base = "WALL", define_as = "WALL_PILLAR_2", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_2.png",z=3}}}

-----------------------------------------
-- Hard Walls
-----------------------------------------
newEntity{
	define_as = "HARDWALL",
	type = "wall", subtype = "floor",
	name = "wall", image = "terrain/granite_wall1.png",
	display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
	z = 3,
	nice_tiler = { method="wall3d", inner={"HARDWALL", 100, 1, 5}, north={"HARDWALL_NORTH", 100, 1, 5}, south={"HARDWALL_SOUTH", 10, 1, 17}, north_south="HARDWALL_NORTH_SOUTH", small_pillar="HARDWALL_SMALL_PILLAR", pillar_2="HARDWALL_PILLAR_2", pillar_8={"HARDWALL_PILLAR_8", 100, 1, 5}, pillar_4="HARDWALL_PILLAR_4", pillar_6="HARDWALL_PILLAR_6" },
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	air_level = -20,
}
for i = 1, 5 do
	newEntity{ base = "HARDWALL", define_as = "HARDWALL"..i, image = "terrain/granite_wall1_"..i..".png", z = 3}
	newEntity{ base = "HARDWALL", define_as = "HARDWALL_NORTH"..i, image = "terrain/granite_wall1_"..i..".png", z = 3, add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}}
	newEntity{ base = "HARDWALL", define_as = "HARDWALL_PILLAR_8"..i, image = "terrain/granite_wall1_"..i..".png", z = 3, add_displays = {class.new{image="terrain/granite_wall_pillar_8.png", z=18, display_y=-1}}}
end
newEntity{ base = "HARDWALL", define_as = "HARDWALL_NORTH_SOUTH", image = "terrain/granite_wall2.png", z = 3, add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}}
newEntity{ base = "HARDWALL", define_as = "HARDWALL_SOUTH", image = "terrain/granite_wall2.png", z = 3}
for i = 1, 17 do newEntity{ base = "HARDWALL", define_as = "HARDWALL_SOUTH"..i, image = "terrain/granite_wall2_"..i..".png", z = 3} end
newEntity{ base = "HARDWALL", define_as = "HARDWALL_SMALL_PILLAR", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_small.png", z=3}, class.new{image="terrain/granite_wall_pillar_small_top.png", z=18, display_y=-1}}}
newEntity{ base = "HARDWALL", define_as = "HARDWALL_PILLAR_6", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_3.png", z=3}, class.new{image="terrain/granite_wall_pillar_9.png", z=18, display_y=-1}}}
newEntity{ base = "HARDWALL", define_as = "HARDWALL_PILLAR_4", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_1.png", z=3}, class.new{image="terrain/granite_wall_pillar_7.png", z=18, display_y=-1}}}
newEntity{ base = "HARDWALL", define_as = "HARDWALL_PILLAR_2", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_2.png", z=3}}}


-----------------------------------------
-- Doors
-----------------------------------------
newEntity{
	define_as = "DOOR",
	type = "wall", subtype = "floor",
	name = "door", image = "terrain/granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="DOOR_VERT", west_east="DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = "DOOR_OPEN",
	dig = "FLOOR",
}
newEntity{
	define_as = "DOOR_OPEN",
	type = "wall", subtype = "floor",
	name = "open door", image="terrain/granite_door1_open.png",
	display = "'", color_r=238, color_g=154, color_b=77, back_color=colors.DARK_GREY,
	always_remember = true,
	is_door = true,
	door_closed = "DOOR",
}
newEntity{ base = "DOOR", define_as = "DOOR_HORIZ", image = "terrain/granite_door1.png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, door_opened = "DOOR_HORIZ_OPEN"}
newEntity{ base = "DOOR_OPEN", define_as = "DOOR_HORIZ_OPEN", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_open.png", z=17}, class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, door_closed = "DOOR_HORIZ"}
newEntity{ base = "DOOR", define_as = "DOOR_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_vert.png", z=17}, class.new{image="terrain/granite_door1_vert_north.png", z=18, display_y=-1}}, door_opened = "DOOR_OPEN_VERT", dig = "DOOR_OPEN_VERT"}
newEntity{ base = "DOOR_OPEN", define_as = "DOOR_OPEN_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_open_vert.png", z=17}, class.new{image="terrain/granite_door1_open_vert_north.png", z=18, display_y=-1}}, door_closed = "DOOR_VERT"}

newEntity{
	define_as = "DOOR_VAULT",
	type = "wall", subtype = "floor",
	name = "sealed door", image = "terrain/granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="DOOR_VAULT_VERT", west_east="DOOR_VAULT_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	is_door = true,
	door_player_check = "This door seems to have been sealed off, you think you can open it.",
	door_opened = "DOOR_OPEN",
}
newEntity{ base = "DOOR_VAULT", define_as = "DOOR_VAULT_HORIZ", image = "terrain/granite_door1.png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, door_opened = "DOOR_HORIZ_OPEN"}
newEntity{ base = "DOOR_VAULT", define_as = "DOOR_VAULT_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_vert.png", z=17}, class.new{image="terrain/granite_door1_vert_north.png", z=18, display_y=-1}}, door_opened = "DOOR_OPEN_VERT"}

-----------------------------------------
-- Old walls
-----------------------------------------
newEntity{
	define_as = "OLD_FLOOR",
	type = "floor", subtype = "floor",
	name = "floor", image = "terrain/oldstone_floor.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
--	nice_tiler = { method="replace", base={"OLD_FLOOR", 100, 1, 4}},
}
--for i = 1, 4 do newEntity{ base = "OLD_FLOOR", define_as = "OLD_FLOOR"..i, image = "terrain/oldstone_floor"..(i > 1 and "_"..i or "")..".png"} end

newEntity{
	define_as = "OLD_WALL",
	type = "wall", subtype = "floor",
	name = "wall", image = "terrain/granite_wall_lichen.png", back_color=colors.GREY,
	display = '#', color_r=255, color_g=255, color_b=255,
	nice_tiler = { method="wall3d", inner={"OLD_WALL", 100, 1, 5}, north={"OLD_WALL_NORTH", 100, 1, 5}, south={"OLD_WALL_SOUTH", 70, 1, 3}, north_south={"OLD_WALL_NORTH_SOUTH", 70, 1, 3}, small_pillar="OLD_WALL_SMALL_PILLAR", pillar_2="OLD_WALL_PILLAR_2", pillar_8={"OLD_WALL_PILLAR_8", 100, 1, 5}, pillar_4="OLD_WALL_PILLAR_4", pillar_6="OLD_WALL_PILLAR_6" },
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	air_level = -20,
}
for i = 1, 5 do
	newEntity{ base = "OLD_WALL", define_as = "OLD_WALL"..i, image = "terrain/granite_wall1_"..i..".png"}
	newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_NORTH"..i, image = "terrain/granite_wall1_"..i..".png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}}
	newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_PILLAR_8"..i, image = "terrain/granite_wall1_"..i..".png", add_displays = {class.new{image="terrain/granite_wall_pillar_8.png", z=18, display_y=-1}}}
end
newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_NORTH_SOUTH", image = "terrain/granite_wall2.png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}}
for i = 1, 3 do newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_NORTH_SOUTH"..i, image = "terrain/granite_wall_lichen_"..i..".png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}} end
newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_SOUTH", image = "terrain/granite_wall2.png"}
for i = 1, 3 do newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_SOUTH"..i, image = "terrain/granite_wall_lichen_"..i..".png"} end
newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_SMALL_PILLAR", image = "terrain/oldstone_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_small.png", z=3}, class.new{image="terrain/granite_wall_pillar_small_top.png", z=18, display_y=-1}}}
newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_PILLAR_6", image = "terrain/oldstone_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_3.png", z=3}, class.new{image="terrain/granite_wall_pillar_9.png", z=18, display_y=-1}}}
newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_PILLAR_4", image = "terrain/oldstone_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_1.png", z=3}, class.new{image="terrain/granite_wall_pillar_7.png", z=18, display_y=-1}}}
newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_PILLAR_2", image = "terrain/oldstone_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_2.png", z=3}}}

-----------------------------------------
-- Glass Walls
-----------------------------------------
newEntity{
	define_as = "GLASSWALL",
	type = "wall", subtype = "floor",
	name = "glass wall", image = "terrain/glasswall.png",
	display = '#', color=colors.AQUAMARINE, back_color=colors.GREY,
	z = 3,
	nice_tiler = { method="wall3d", inner="GLASSWALLF", north="GLASSWALL_NORTH", south="GLASSWALL_SOUTH", north_south="GLASSWALL_NORTH_SOUTH", small_pillar="GLASSWALL_SMALL_PILLAR", pillar_2="GLASSWALL_PILLAR_2", pillar_8="GLASSWALL_PILLAR_8", pillar_4="GLASSWALL_PILLAR_4" },
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	air_level = -20,
	dig = "FLOOR",
}
newEntity{ base = "GLASSWALL", define_as = "GLASSWALLF", image = "terrain/marble_floor.png",add_mos={{image = "terrain/glass/wall_glass_middle_01_64.png"}}}
newEntity{ base = "GLASSWALL", define_as = "GLASSWALL_NORTH", image = "terrain/marble_floor.png",add_mos={{image = "terrain/glass/wall_glass_middle_01_64.png"}}, z = 3, add_displays = {class.new{image="terrain/glass/wall_glass_top_01_64.png", z=18, display_y=-1}}}
newEntity{ base = "GLASSWALL", define_as = "GLASSWALL_NORTH_SOUTH", image = "terrain/marble_floor.png",add_mos={{image = "terrain/glass/wall_glass_01_64.png"}}, z = 3, add_displays = {class.new{image="terrain/glass/wall_glass_top_01_64.png", z=18, display_y=-1}}}
newEntity{ base = "GLASSWALL", define_as = "GLASSWALL_SOUTH", image = "terrain/marble_floor.png",add_mos={{image = "terrain/glass/wall_glass_01_64.png"}}, z = 3}
newEntity{ base = "GLASSWALL_NORTH_SOUTH", define_as = "GLASSWALL_PILLAR_6"}
newEntity{ base = "GLASSWALL_NORTH_SOUTH", define_as = "GLASSWALL_PILLAR_4"}
newEntity{ base = "GLASSWALL_NORTH_SOUTH", define_as = "GLASSWALL_SMALL_PILLAR"}
newEntity{ base = "GLASSWALL_NORTH", define_as = "GLASSWALL_PILLAR_8"}
newEntity{ base = "GLASSWALL_SOUTH", define_as = "GLASSWALL_PILLAR_2"}

-----------------------------------------
-- Glass Doors
-----------------------------------------
newEntity{
	define_as = "GLASSDOOR",
	type = "wall", subtype = "floor",
	name = "glass door", image = "terrain/glassdoor.png",
	display = '+', color=colors.AQUAMARINE, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="GLASSDOOR_VERT", west_east="GLASSDOOR_HORIZ" },
	notice = true,
	always_remember = true,
	is_door = true,
	door_opened = "GLASSDOOR_OPEN",
	dig = "FLOOR",
}
newEntity{
	define_as = "GLASSDOOR_OPEN",
	type = "wall", subtype = "floor",
	name = "open glass door", image="terrain/glassdoor.png",
	display = "'", color=colors.AQUAMARINE, back_color=colors.DARK_GREY,
	always_remember = true,
	is_door = true,
	door_closed = "GLASSDOOR",
}
newEntity{ base = "GLASSDOOR", define_as = "GLASSDOOR_HORIZ", image = "terrain/marble_floor.png", add_mos={{image = "terrain/glass/glass_door_hor_closed_01_64.png"}}, add_displays = {class.new{image="terrain/glass/wall_glass_top_01_64.png", z=18, display_y=-1}}, door_opened = "GLASSDOOR_HORIZ_OPEN"}
newEntity{ base = "GLASSDOOR_OPEN", define_as = "GLASSDOOR_HORIZ_OPEN", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/glass/glass_door_hor_open_01_64.png", z=17}, class.new{image="terrain/glass/wall_glass_top_01_64.png", z=18, display_y=-1}}, door_closed = "GLASSDOOR_HORIZ"}
newEntity{ base = "GLASSDOOR", define_as = "GLASSDOOR_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/glass/glass_door_ver_bottom_closed_01_64.png", z=17}, class.new{image="terrain/glass/glass_door_ver_top_closed_01_64.png", z=18, display_y=-1}}, door_opened = "GLASSDOOR_OPEN_VERT", dig = "GLASSDOOR_OPEN_VERT"}
newEntity{ base = "GLASSDOOR_OPEN", define_as = "GLASSDOOR_OPEN_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/glass/glass_door_ver_bottom_open_01_64.png", z=17}, class.new{image="terrain/glass/glass_door_ver_top_closed_01_64.png", z=18, display_y=-1}}, door_closed = "GLASSDOOR_VERT"}


-----------------------------------------
-- Levers & such tricky tings
-----------------------------------------
newEntity{
	define_as = "GENERIC_LEVER_DOOR",
	type = "wall", subtype = "floor",
	name = "sealed door", image = "terrain/granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="GENERIC_LEVER_DOOR_VERT", west_east="GENERIC_LEVER_DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	force_clone = true,
	door_player_stop = "This door seems to have been sealed off, you need to find a way to open it.",
	is_door = true,
	door_opened = "GENERIC_LEVER_DOOR_OPEN",
	on_lever_change = function(self, x, y, who, val, oldval)
		local toggle = game.level.map.attrs(x, y, "lever_toggle")
		local trigger = game.level.map.attrs(x, y, "lever_action")
		if toggle or (val > oldval and val >= trigger) then
			game.level.map(x, y, engine.Map.TERRAIN, game.zone.grid_list[self.door_opened])
			game.log("#VIOLET#You hear a door opening.")
			return true
		end
	end,
}
newEntity{ base = "GENERIC_LEVER_DOOR", define_as = "GENERIC_LEVER_DOOR_HORIZ", image = "terrain/granite_door1.png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1, add_mos={{image="terrain/padlock2.png", display_y=0.1}}}}, door_opened = "DOOR_HORIZ_OPEN"}
newEntity{ base = "GENERIC_LEVER_DOOR", define_as = "GENERIC_LEVER_DOOR_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_vert.png", z=17, add_mos={{image="terrain/padlock2.png", display_x=0.2, display_y=-0.4}}}, class.new{image="terrain/granite_door1_vert_north.png", z=18, display_y=-1}}, door_opened = "DOOR_OPEN_VERT"}

newEntity{
	define_as = "GENERIC_LEVER_DOOR_OPEN",
	type = "wall", subtype = "floor",
	name = "open door", image="terrain/granite_door1_open.png",
	display = "'", color_r=238, color_g=154, color_b=77, back_color=colors.DARK_GREY,
	nice_tiler = { method="door3d", north_south="GENERIC_LEVER_DOOR_OPEN_VERT", west_east="GENERIC_LEVER_DOOR_HORIZ_OPEN" },
	always_remember = true,
	is_door = true,
	door_closed = "GENERIC_LEVER_DOOR",
	door_player_stop = "This door seems to have been sealed off, you need to find a way to close it.",
	on_lever_change = function(self, x, y, who, val, oldval)
		local toggle = game.level.map.attrs(x, y, "lever_toggle")
		local trigger = game.level.map.attrs(x, y, "lever_action")
		if toggle or (val < oldval and val < trigger) then
			game.level.map(x, y, engine.Map.TERRAIN, game.zone.grid_list[self.door_closed])
			game.log("#VIOLET#You hear a door closing.")
			return true
		end
	end,
}
newEntity{ base = "GENERIC_LEVER_DOOR_OPEN", define_as = "GENERIC_LEVER_DOOR_HORIZ_OPEN", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_open.png", z=17}, class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, door_closed = "GENERIC_LEVER_DOOR_HORIZ"}
newEntity{ base = "GENERIC_LEVER_DOOR_OPEN", define_as = "GENERIC_LEVER_DOOR_OPEN_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_open_vert.png", z=17}, class.new{image="terrain/granite_door1_open_vert_north.png", z=18, display_y=-1}}, door_closed = "GENERIC_LEVER_DOOR_VERT"}

newEntity{
	define_as = "GENERIC_LEVER",
	type = "lever", subtype = "floor",
	name = "huge lever", image = "terrain/marble_floor.png", add_mos = {{image="terrain/lever1_state1.png"}},
	display = '&', color=colors.UMBER, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	lever = false,
	force_clone = true,
	block_move = function(self, x, y, e, act)
		if act and e.player then
			local spot = game.level.map.attrs(x, y, "lever_spot") or nil
			local block = game.level.map.attrs(x, y, "lever_block") or nil
			local radius = game.level.map.attrs(x, y, "lever_radius") or 10
			local val = game.level.map.attrs(x, y, "lever")
			local kind = game.level.map.attrs(x, y, "lever_kind")
			if type(kind) == "string" then kind = {[kind]=true} end
			if self.lever then
				self.color_r = colors.UMBER.r self.color_g = colors.UMBER.g self.color_b = colors.UMBER.b
				self.add_mos[1].image = "terrain/lever1_state1.png"
			else
				self.color_r = 255 self.color_g = 255 self.color_b = 255
				self.add_mos[1].image = "terrain/lever1_state2.png"
			end
			self:removeAllMOs()
			game.level.map:updateMap(x, y)
			self.lever = not self.lever
			game.log("#VIOLET#You hear a mechanism clicking.")

			local apply = function(i, j)
				local akind = game.level.map.attrs(i, j, "lever_action_kind")
				if not akind then return end
				if type(akind) == "string" then akind = {[akind]=true} end
				for k, _ in pairs(kind) do if akind[k] then
					local old = game.level.map.attrs(i, j, "lever_action_value") or 0
					local newval = old + (self.lever and val or -val)
					game.level.map.attrs(i, j, "lever_action_value", newval)
					if game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "on_lever_change", e, newval, old) then
						if game.level.map.attrs(i, j, "lever_action_only_once") then game.level.map.attrs(i, j, "lever_action_kind", false) end
					end
					local fct = game.level.map.attrs(i, j, "lever_action_custom")
					if fct and fct(i, j, e, newval, old) then
						if game.level.map.attrs(i, j, "lever_action_only_once") then game.level.map.attrs(i, j, "lever_action_kind", false) end
					end
				end end
			end

			if spot then
				local spot = game.level:pickSpot(spot)
				if spot then apply(spot.x, spot.y) end
			else
				core.fov.calc_circle(x, y, game.level.map.w, game.level.map.h, radius, function(_, i, j)
					if block and game.level.map.attrs(i, j, block) then return true end
				end, function(_, i, j) apply(i, j) end, nil)
			end
		end
		return true
	end,
}
