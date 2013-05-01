-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

local sand_editer = { method="borders_def", def="sand"}
local bone_wall_editer = { method="sandWalls_def", def="bonewall"}

newEntity{
	define_as = "BONEFLOOR",
	type = "floor", subtype = "bone",
	name = "sand", image = "terrain/sandfloor.png",
	display = '.', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	nice_editer = sand_editer,
	grow = "BONEWALL",
}

newEntity{
	define_as = "BONEWALL",
	type = "wall", subtype = "bone",
	name = "bone walls", image = "terrain/bone/bonewall_5_1.png",
	display = '#', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	dig = "BONEFLOOR",
	nice_editer = bone_wall_editer,
	nice_tiler = { method="replace", base={"BONEWALL", 20, 1, 6}},
}
for i = 1, 6 do newEntity{ base = "BONEWALL", define_as = "BONEWALL"..i, image = "terrain/bone/bonewall_5_"..i..".png"} end

newEntity{
	define_as = "HARDBONEWALL",
	type = "wall", subtype = "bone",
	name = "bone walls", image = "terrain/bone/bonewall_5_1.png",
	display = '#', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	always_remember = true,
	can_pass = {pass_wall=1},
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	air_level = -15,
	nice_editer = bone_wall_editer,
	nice_tiler = { method="replace", base={"HARDBONEWALL", 20, 1, 6}},
}
for i = 1, 6 do newEntity{ base = "HARDBONEWALL", define_as = "HARDBONEWALL"..i, image = "terrain/bone/bonewall_5_"..i..".png"} end

-----------------------------------------
-- Cavy exits
-----------------------------------------

newEntity{
	define_as = "BONE_LADDER_DOWN",
	type = "floor", subtype = "bone",
	name = "ladder to the next level", image = "terrain/bone/bone_floor_1_01.png", add_displays = {class.new{image="terrain/bone/bone_stairs_down_3_01.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "BONE_LADDER_UP",
	type = "floor", subtype = "bone",
	name = "ladder to the previous level", image = "terrain/bone/bone_floor_1_01.png", add_displays = {class.new{image="terrain/bone/bone_stairs_up_2_01.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "BONE_LADDER_UP_WILDERNESS",
	type = "floor", subtype = "bone",
	name = "ladder to worldmap", image = "terrain/bone/bone_floor_1_01.png", add_displays = {class.new{image="terrain/bone/bone_stairs_up_2_01.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}
