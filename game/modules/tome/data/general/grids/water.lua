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

------------------------------------------------------------
-- For inside the sea
------------------------------------------------------------

newEntity{
	define_as = "WATER_FLOOR",
	name = "underwater", image = "terrain/water_floor.png",
	display = '.', color=colors.LIGHT_BLUE, back_color=colors.DARK_BLUE,
	add_displays = class:makeWater(true),
	air_level = -5, air_condition="water",
}
for i = 2, 20 do
newEntity{
	define_as = "WATER_FLOOR"..i,
	name = "underwater", image = "terrain/water_floor.png",
	display = '.', color=colors.LIGHT_BLUE, back_color=colors.DARK_BLUE,
	add_displays = class:mergeSubEntities(class:makeWater(true), class:makeShells("terrain/shell")),
	air_level = -5, air_condition="water",
}
end

newEntity{
	define_as = "WATER_WALL",
	name = "coral wall", image = "terrain/water_wall.png",
	display = '#', color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	add_displays = class:makeWater(true),
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -5,
}
newEntity{
	define_as = "WATER_DOOR",
	name = "coral door", image = "terrain/granite_door1.png",
	display = '+', color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	add_displays = class:makeWater(true),
	notice = true,
	always_remember = true,
	block_sight = true,
	door_opened = "WATER_DOOR_OPEN",
	dig = "WATER_DOOR_OPEN",
	air_level = -5, air_condition="water",
}
newEntity{
	define_as = "WATER_DOOR_OPEN",
	name = "open coral door", image = "terrain/granite_door1_open.png",
	display = "'", color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	add_displays = class:makeWater(true),
	always_remember = true,
	door_closed = "WATER_DOOR",
	air_level = -5, air_condition="water",
}

------------------------------------------------------------
-- For outside
------------------------------------------------------------

newEntity{
	define_as = "WATER_BASE",
	type = "floor", subtype = "water",
	name = "deep water", image = "terrain/water_floor.png",
	display = '~', color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	always_remember = true,
	air_level = -5, air_condition="water",
}

newEntity{ base="WATER_BASE",
	define_as = "DEEP_WATER",
	add_displays = class:makeWater(true),
	nice_tiler = { method="water",
		water="WATER_GRASS_5", grass8={"WATER_GRASS_8", 100, 1, 2}, grass2={"WATER_GRASS_2", 100, 1, 2}, grass4={"WATER_GRASS_4", 100, 1, 2}, grass6={"WATER_GRASS_6", 100, 1, 2}, grass1={"WATER_GRASS_1", 100, 1, 2}, grass3={"WATER_GRASS_3", 100, 1, 2}, grass7={"WATER_GRASS_7", 100, 1, 2}, grass9={"WATER_GRASS_9", 100, 1, 2}, inner_grass1="WATER_GRASS_1I", inner_grass3="WATER_GRASS_3I", inner_grass7="WATER_GRASS_7I", inner_grass9="WATER_GRASS_9I"
	},
}

newEntity{base="WATER_BASE", define_as = "WATER_GRASS_5", image="terrain/water_grass_5_1.png"}
for i = 1, 9 do for j = 1, 2 do
	if i ~= 5 then newEntity{base="WATER_BASE", define_as = "WATER_GRASS_"..i..j, image="terrain/water_grass_"..i.."_"..j..".png"} end
end end
newEntity{base="WATER_BASE", define_as = "WATER_GRASS_1I", image="terrain/water_grass_1i_1.png"}
newEntity{base="WATER_BASE", define_as = "WATER_GRASS_3I", image="terrain/water_grass_3i_1.png"}
newEntity{base="WATER_BASE", define_as = "WATER_GRASS_7I", image="terrain/water_grass_7i_1.png"}
newEntity{base="WATER_BASE", define_as = "WATER_GRASS_9I", image="terrain/water_grass_9i_1.png"}

newEntity{
	define_as = "POISON_DEEP_WATER",
	name = "poisoned deep water", image = "terrain/water_floor.png",
	display = '~', color=colors.YELLOW_GREEN, back_color=colors.DARK_GREEN,
	add_displays = class:makeWater(true, "poison_"),
	always_remember = true,
	air_level = -5, air_condition="water",
}

-----------------------------------------
-- Water/grass
-----------------------------------------


-----------------------------------------
-- Dungeony exits
-----------------------------------------
newEntity{
	define_as = "WATER_UP_WILDERNESS",
	name = "exit to the worldmap", image = "terrain/water_stair_up_wild.png",
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "WATER_UP", image = "terrain/water_stair_up.png",
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "WATER_DOWN", image = "terrain/water_stair_down.png",
	name = "next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
