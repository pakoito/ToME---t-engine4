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

load("/data/general/grids/basic.lua")
load("/data/general/grids/void.lua")

newEntity{
	define_as = "RIFT",
	name = "Temporal Rift", add_mos={{image="terrain/demon_portal2.png"}},
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[The rift leads to an other part of the morass.]],
	change_level = 1,
}

newEntity{
	define_as = "RIFT_HOME",
	name = "Temporal Rift", add_mos={{image="terrain/demon_portal2.png"}},
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[The rift leads to an other part of the morass.]],
	change_level = 1,
	change_zone = "town-point-zero",
}

local rift_editer = { method="sandWalls_def", def="rift"}
newEntity{
	define_as = "SPACETIME_RIFT",
	type = "wall", subtype = "rift",
	name = "crack in spacetime",
	display = '#', color=colors.YELLOW, image="terrain/rift/rift_inner_05_01.png",
	always_remember = true,
	block_sight = true,
	does_block_move = true,
	_noalpha = false,
	nice_editer = rift_editer,
}
