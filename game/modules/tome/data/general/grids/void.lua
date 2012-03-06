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

local rift_editer = { method="sandWalls_def", def="rift"}

newEntity{
	define_as = "VOID",
	type = "floor", subtype = "void",
	name = "void",
	display = ' ',
	_noalpha = false,
}

newEntity{
	define_as = "OUTERSPACE",
	type = "void", subtype = "void",
	name = "void",
	display = ' ',
	_noalpha = false,
	always_remember = true,
	does_block_move = true,
	pass_projectile = true,
	air_level = -40,
	is_void = true,
	can_pass = {pass_void=1},
}

newEntity{
	define_as = "SPACETIME_RIFT",
	type = "wall", subtype = "rift",
	name = "crack in spacetime",
	display = '#', color=colors.YELLOW, image="terrain/rift/rift_inner_05_01.png",
	always_remember = true,
	does_block_move = true,
	_noalpha = false,
	nice_editer = rift_editer,
}

-----------------------------------------
-- Floating platforms
-----------------------------------------

newEntity{
	define_as = "FLOATING_ROCKS",
	type = "floor", subtype = "rocks",
	name = "floating rocks", image = "terrain/floating_rocks05_01.png",
	display = '.', color_r=255, color_g=255, color_b=255,
	_noalpha = false,
	nice_tiler = { method="outerSpace",
		replace_wrong="OUTERSPACE",
		rocks="FLOATING_ROCKS_5",
		void8={"FLOATING_ROCKS_8", 100, 1, 1}, void2={"FLOATING_ROCKS_2", 100, 1, 1}, void4={"FLOATING_ROCKS_4", 100, 1, 1}, void6={"FLOATING_ROCKS_6", 100, 1, 1}, void1={"FLOATING_ROCKS_1", 100, 1, 1}, void3={"FLOATING_ROCKS_3", 100, 1, 1}, void7={"FLOATING_ROCKS_7", 100, 1, 1}, void9={"FLOATING_ROCKS_9", 100, 1, 1}, inner_void1="FLOATING_ROCKS_1I", inner_void3="FLOATING_ROCKS_3I", inner_void7="FLOATING_ROCKS_7I", inner_void9="FLOATING_ROCKS_9I",
	},
}

newEntity{base="FLOATING_ROCKS", define_as = "FLOATING_ROCKS_5", image="terrain/floating_rocks05_01.png"}
for i = 1, 9 do for j = 1, 1 do
	if i ~= 5 then newEntity{base="FLOATING_ROCKS", define_as = "FLOATING_ROCKS_"..i..j, image="terrain/floating_rocks0"..i.."_0"..j..".png"} end
end end
newEntity{base="FLOATING_ROCKS", define_as = "FLOATING_ROCKS_1I", image="terrain/floating_rocks_inner01_01.png"}
newEntity{base="FLOATING_ROCKS", define_as = "FLOATING_ROCKS_3I", image="terrain/floating_rocks_inner03_01.png"}
newEntity{base="FLOATING_ROCKS", define_as = "FLOATING_ROCKS_7I", image="terrain/floating_rocks_inner07_01.png"}
newEntity{base="FLOATING_ROCKS", define_as = "FLOATING_ROCKS_9I", image="terrain/floating_rocks_inner09_01.png"}
