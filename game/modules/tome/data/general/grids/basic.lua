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

-----------------------------------------
-- Dungeony exits
-----------------------------------------
newEntity{
	define_as = "UP_WILDERNESS",
	name = "exit to the worldmap", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/stair_up_wild.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "UP", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/stair_up.png"}},
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "DOWN", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/stair_down.png"}},
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
	name = "exit to the worldmap", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/worldmap.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "FLAT_UP8",
	name = "way to the previous level", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "FLAT_UP2",
	name = "way to the previous level", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "FLAT_UP4",
	name = "way to the previous level", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "FLAT_UP6",
	name = "way to the previous level", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "FLAT_DOWN8",
	name = "way to the next level", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "FLAT_DOWN2",
	name = "way to the next level", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "FLAT_DOWN4",
	name = "way to the next level", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "FLAT_DOWN6",
	name = "way to the next level", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
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
	name = "floor", image = "terrain/marble_floor.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
	grow = "WALL",
}

-----------------------------------------
-- Walls
-----------------------------------------
newEntity{
	define_as = "WALL",
	name = "wall", image = "terrain/granite_wall1.png",
	display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
	nice_tiler = { method="wall3d", inner={"WALL", 100, 1, 5}, north={"WALL_NORTH", 100, 1, 5}, south={"WALL_SOUTH", 10, 1, 17}, north_south="WALL_NORTH_SOUTH", small_pillar="WALL_SMALL_PILLAR", pillar_2="WALL_PILLAR_2", pillar_8={"WALL_PILLAR_8", 100, 1, 5}, pillar_4="WALL_PILLAR_4", pillar_6="WALL_PILLAR_6" },
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -20,
	dig = "FLOOR",
}
for i = 1, 5 do
	newEntity{ base = "WALL", define_as = "WALL"..i, image = "terrain/granite_wall1_"..i..".png", nice_tiler = false}
	newEntity{ base = "WALL", define_as = "WALL_NORTH"..i, image = "terrain/granite_wall1_"..i..".png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, nice_tiler = false}
	newEntity{ base = "WALL", define_as = "WALL_PILLAR_8"..i, image = "terrain/granite_wall1_"..i..".png", add_displays = {class.new{image="terrain/granite_wall_pillar_8.png", z=18, display_y=-1}}, nice_tiler = false}
end
newEntity{ base = "WALL", define_as = "WALL_NORTH_SOUTH", image = "terrain/granite_wall2.png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, nice_tiler = false}
newEntity{ base = "WALL", define_as = "WALL_SOUTH", image = "terrain/granite_wall2.png", nice_tiler = false}
for i = 1, 17 do newEntity{ base = "WALL", define_as = "WALL_SOUTH"..i, image = "terrain/granite_wall2_"..i..".png", nice_tiler = false} end
newEntity{ base = "WALL", define_as = "WALL_SMALL_PILLAR", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_small.png"}, class.new{image="terrain/granite_wall_pillar_small_top.png", z=18, display_y=-1}}, nice_tiler = false}
newEntity{ base = "WALL", define_as = "WALL_PILLAR_6", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_3.png"}, class.new{image="terrain/granite_wall_pillar_9.png", z=18, display_y=-1}}, nice_tiler = false}
newEntity{ base = "WALL", define_as = "WALL_PILLAR_4", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_1.png"}, class.new{image="terrain/granite_wall_pillar_7.png", z=18, display_y=-1}}, nice_tiler = false}
newEntity{ base = "WALL", define_as = "WALL_PILLAR_2", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_2.png"}}, nice_tiler = false}

-----------------------------------------
-- Big Walls
-----------------------------------------
newEntity{
	define_as = "BIGWALL",
	name = "wall", image = "terrain/bigwall.png",
	display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -20,
	dig = "FLOOR",
}

-----------------------------------------
-- Hard Walls
-----------------------------------------
newEntity{
	define_as = "HARDWALL",
	name = "wall", image = "terrain/granite_wall1.png",
	display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
	nice_tiler = { method="wall3d", inner={"WALL", 100, 1, 5}, north={"WALL_NORTH", 100, 1, 5}, south={"WALL_SOUTH", 10, 1, 17}, north_south="WALL_NORTH_SOUTH", small_pillar="WALL_SMALL_PILLAR", pillar_2="WALL_PILLAR_2", pillar_8={"WALL_PILLAR_8", 100, 1, 5}, pillar_4="WALL_PILLAR_4", pillar_6="WALL_PILLAR_6" },
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	air_level = -20,
}
for i = 1, 5 do
	newEntity{ base = "HARDWALL", define_as = "HARDWALL"..i, image = "terrain/granite_wall1_"..i..".png", nice_tiler = false}
	newEntity{ base = "HARDWALL", define_as = "HARDWALL_NORTH"..i, image = "terrain/granite_wall1_"..i..".png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, nice_tiler = false}
	newEntity{ base = "HARDWALL", define_as = "HARDWALL_PILLAR_8"..i, image = "terrain/granite_wall1_"..i..".png", add_displays = {class.new{image="terrain/granite_wall_pillar_8.png", z=18, display_y=-1}}, nice_tiler = false}
end
newEntity{ base = "HARDWALL", define_as = "HARDWALL_NORTH_SOUTH", image = "terrain/granite_wall2.png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, nice_tiler = false}
newEntity{ base = "HARDWALL", define_as = "HARDWALL_SOUTH", image = "terrain/granite_wall2.png", nice_tiler = false}
for i = 1, 17 do newEntity{ base = "HARDWALL", define_as = "HARDWALL_SOUTH"..i, image = "terrain/granite_wall2_"..i..".png", nice_tiler = false} end
newEntity{ base = "HARDWALL", define_as = "HARDWALL_SMALL_PILLAR", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_small.png"}, class.new{image="terrain/granite_wall_pillar_small_top.png", z=18, display_y=-1}}, nice_tiler = false}
newEntity{ base = "HARDWALL", define_as = "HARDWALL_PILLAR_6", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_3.png"}, class.new{image="terrain/granite_wall_pillar_9.png", z=18, display_y=-1}}, nice_tiler = false}
newEntity{ base = "HARDWALL", define_as = "HARDWALL_PILLAR_4", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_1.png"}, class.new{image="terrain/granite_wall_pillar_7.png", z=18, display_y=-1}}, nice_tiler = false}
newEntity{ base = "HARDWALL", define_as = "HARDWALL_PILLAR_2", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_2.png"}}, nice_tiler = false}


-----------------------------------------
-- Doors
-----------------------------------------
newEntity{
	define_as = "DOOR",
	name = "door", image = "terrain/granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="DOOR_VERT", west_east="DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	door_opened = "DOOR_OPEN",
	dig = "FLOOR",
}
newEntity{
	define_as = "DOOR_OPEN",
	name = "open door", image="terrain/granite_door1_open.png",
	display = "'", color_r=238, color_g=154, color_b=77, back_color=colors.DARK_GREY,
	always_remember = true,
	door_closed = "DOOR",
}
newEntity{ base = "DOOR", define_as = "DOOR_HORIZ", image = "terrain/granite_door1.png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, nice_tiler = false, door_opened = "DOOR_HORIZ_OPEN"}
newEntity{ base = "DOOR_OPEN", define_as = "DOOR_HORIZ_OPEN", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_open.png", z=17}, class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, nice_tiler = false, door_closed = "DOOR_HORIZ"}
newEntity{ base = "DOOR", define_as = "DOOR_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_vert.png", z=17}, class.new{image="terrain/granite_door1_vert_north.png", z=18, display_y=-1}}, door_opened = "DOOR_OPEN_VERT", nice_tiler = false, dig = "DOOR_OPEN_VERT"}
newEntity{ base = "DOOR_OPEN", define_as = "DOOR_OPEN_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_open_vert.png", z=17}, class.new{image="terrain/granite_door1_open_vert_north.png", z=18, display_y=-1}}, nice_tiler = false, door_closed = "DOOR_VERT"}

newEntity{
	define_as = "DOOR_VAULT",
	name = "sealed door", image = "terrain/granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="DOOR_VAULT_VERT", west_east="DOOR_VAULT_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	door_player_check = "This door seems to have been sealed off, you think you can open it.",
	door_opened = "DOOR_OPEN",
}
newEntity{ base = "DOOR_VAULT", define_as = "DOOR_VAULT_HORIZ", image = "terrain/granite_door1.png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, nice_tiler = false, door_opened = "DOOR_HORIZ_OPEN"}
newEntity{ base = "DOOR_VAULT", define_as = "DOOR_VAULT_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_vert.png", z=17}, class.new{image="terrain/granite_door1_vert_north.png", z=18, display_y=-1}}, door_opened = "DOOR_OPEN_VERT", nice_tiler = false}

-----------------------------------------
-- Old walls
-----------------------------------------
newEntity{
	define_as = "OLD_FLOOR",
	name = "floor", image = "terrain/oldstone_floor.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
--	nice_tiler = { method="replace", base={"OLD_FLOOR", 100, 1, 4}},
}
--for i = 1, 4 do newEntity{ base = "OLD_FLOOR", define_as = "OLD_FLOOR"..i, image = "terrain/oldstone_floor"..(i > 1 and "_"..i or "")..".png", nice_tiler = false} end

newEntity{
	define_as = "OLD_WALL",
	name = "wall", image = "terrain/granite_wall_lichen.png", back_color=colors.GREY,
	display = '#', color_r=255, color_g=255, color_b=255,
	nice_tiler = { method="wall3d", inner={"OLD_WALL", 100, 1, 5}, north={"OLD_WALL_NORTH", 100, 1, 5}, south={"OLD_WALL_SOUTH", 70, 1, 3}, north_south={"OLD_WALL_NORTH_SOUTH", 70, 1, 3}, small_pillar="OLD_WALL_SMALL_PILLAR", pillar_2="OLD_WALL_PILLAR_2", pillar_8={"OLD_WALL_PILLAR_8", 100, 1, 5}, pillar_4="OLD_WALL_PILLAR_4", pillar_6="OLD_WALL_PILLAR_6" },
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	air_level = -20,
}
for i = 1, 5 do
	newEntity{ base = "OLD_WALL", define_as = "OLD_WALL"..i, image = "terrain/granite_wall1_"..i..".png", nice_tiler = false}
	newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_NORTH"..i, image = "terrain/granite_wall1_"..i..".png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, nice_tiler = false}
	newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_PILLAR_8"..i, image = "terrain/granite_wall1_"..i..".png", add_displays = {class.new{image="terrain/granite_wall_pillar_8.png", z=18, display_y=-1}}, nice_tiler = false}
end
newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_NORTH_SOUTH", image = "terrain/granite_wall2.png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, nice_tiler = false}
for i = 1, 3 do newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_NORTH_SOUTH"..i, image = "terrain/granite_wall_lichen_"..i..".png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, nice_tiler = false} end
newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_SOUTH", image = "terrain/granite_wall2.png", nice_tiler = false}
for i = 1, 3 do newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_SOUTH"..i, image = "terrain/granite_wall_lichen_"..i..".png", nice_tiler = false} end
newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_SMALL_PILLAR", image = "terrain/oldstone_floor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_small.png"}, class.new{image="terrain/granite_wall_pillar_small_top.png", z=18, display_y=-1}}, nice_tiler = false}
newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_PILLAR_6", image = "terrain/oldstone_floor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_3.png"}, class.new{image="terrain/granite_wall_pillar_9.png", z=18, display_y=-1}}, nice_tiler = false}
newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_PILLAR_4", image = "terrain/oldstone_floor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_1.png"}, class.new{image="terrain/granite_wall_pillar_7.png", z=18, display_y=-1}}, nice_tiler = false}
newEntity{ base = "OLD_WALL", define_as = "OLD_WALL_PILLAR_2", image = "terrain/oldstone_floor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_2.png"}}, nice_tiler = false}
