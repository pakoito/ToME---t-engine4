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

local cave_wall_editer = { method="sandWalls_def", def="cavewall"}

newEntity{
	define_as = "CAVEFLOOR",
	type = "floor", subtype = "cave",
	name = "cave floor", image = "terrain/cave/cave_floor_1_01.png",
	display = '.', color=colors.SANDY_BROWN, back_color=colors.DARK_UMBER,
	grow = "CAVEWALL",
	nice_tiler = { method="replace", base={"CAVEFLOOR", 20, 1, 18}},
}
for i = 1, 18 do
	if i <= 7 then newEntity{ base = "CAVEFLOOR", define_as = "CAVEFLOOR"..i, image = "terrain/cave/cave_floor_"..i.."_01.png"}
	elseif i <= 16 then newEntity{ base = "CAVEFLOOR", define_as = "CAVEFLOOR"..i, image = "terrain/cave/cave_floor_1_01.png", add_mos={{image="terrain/cave/cave_rock_"..(i-7).."_01.png"}}}
	else newEntity{ base = "CAVEFLOOR", define_as = "CAVEFLOOR"..i, image = "terrain/cave/cave_floor_1_01.png", add_mos={{image="terrain/cave/cave_mushroom_"..(i-16).."_01.png"}}}
	end
end

newEntity{
	define_as = "CAVEWALL",
	type = "wall", subtype = "cave",
	name = "cave walls", image = "terrain/cave/cavewall_5_1.png",
	display = '#', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	dig = "CAVEFLOOR",
	nice_editer = cave_wall_editer,
--	nice_tiler = { method="replace", base={"CAVEWALL", 20, 1, 6}},
}
--for i = 1, 6 do newEntity{ base = "CAVEWALL", define_as = "CAVEWALL"..i, image = "terrain/cave/cavewall_5_"..i..".png"} end

-----------------------------------------
-- Cavy exits
-----------------------------------------

newEntity{
	define_as = "CAVE_LADDER_DOWN",
	type = "floor", subtype = "cave",
	name = "ladder to the next level", image = "terrain/cave/cave_floor_1_01.png", add_displays = {class.new{image="terrain/cave/cave_stairs_down_3_01.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "CAVE_LADDER_UP",
	type = "floor", subtype = "cave",
	name = "ladder to the previous level", image = "terrain/cave/cave_floor_1_01.png", add_displays = {class.new{image="terrain/cave/cave_stairs_up_2_01.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "CAVE_LADDER_UP_WILDERNESS",
	type = "floor", subtype = "cave",
	name = "ladder to worldmap", image = "terrain/cave/cave_floor_1_01.png", add_displays = {class.new{image="terrain/cave/cave_stairs_up_2_01.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}
