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

local icecave_wall_editer = { method="sandWalls_def", def="icecavewall"}

newEntity{
	define_as = "ICECAVEFLOOR",
	type = "floor", subtype = "icecave",
	name = "ice cave floor", image = "terrain/icecave/icecave_floor_1_01.png",
	display = '.', color=colors.SANDY_BROWN, back_color=colors.DARK_UMBER,
	grow = "ICECAVEWALL",
	nice_tiler = { method="replace", base={"ICECAVEFLOOR", 100, 1, 18}},
}
for i = 1, 8 + 7 do
	if i <= 8 then newEntity{ base = "ICECAVEFLOOR", define_as = "ICECAVEFLOOR"..i, image = "terrain/icecave/icecave_floor_"..i.."_01.png"}
	elseif i <= 8 + 7 then newEntity{ base = "ICECAVEFLOOR", define_as = "ICECAVEFLOOR"..i, image = "terrain/icecave/icecave_floor_1_01.png", add_mos={{image="terrain/icecave/icecave_rock_"..(i-7).."_01.png"}}}
	end
end

newEntity{
	define_as = "ICECAVEWALL",
	type = "wall", subtype = "icecave",
	name = "ice cave walls", image = "terrain/icecave/icecavewall_5_1.png",
	display = '#', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	dig = "ICECAVEFLOOR",
	nice_editer = icecave_wall_editer,
	nice_tiler = { method="replace", base={"ICECAVEWALL", 100, 1, 9}},
}
for i = 1, 8 do newEntity{ base = "ICECAVEWALL", define_as = "ICECAVEWALL"..i, image = "terrain/icecave/icecavewall_5_"..i..".png"} end

-----------------------------------------
-- Cavy exits
-----------------------------------------

newEntity{
	define_as = "ICECAVE_LADDER_DOWN",
	type = "floor", subtype = "icecave",
	name = "ladder to the next level", image = "terrain/icecave/icecave_floor_1_01.png", add_displays = {class.new{image="terrain/icecave/icecave_stairs_down_3_01.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "ICECAVE_LADDER_UP",
	type = "floor", subtype = "icecave",
	name = "ladder to the previous level", image = "terrain/icecave/icecave_floor_1_01.png", add_displays = {class.new{image="terrain/icecave/icecave_stairs_up_2_01.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "ICECAVE_LADDER_UP_WILDERNESS",
	type = "floor", subtype = "icecave",
	name = "ladder to worldmap", image = "terrain/icecave/icecave_floor_1_01.png", add_displays = {class.new{image="terrain/icecave/icecave_stairs_up_2_01.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}
