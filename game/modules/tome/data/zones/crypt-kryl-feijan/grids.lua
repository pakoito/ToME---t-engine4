-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

newEntity{
	define_as = "LOCK",
	type = "floor", subtype = "floor",
	name = "sealed door", image = "terrain/granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="LOCK_VERT", west_east="LOCK_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	does_block_move = true,
}
newEntity{ base = "LOCK", define_as = "LOCK_HORIZ", z=3, image = "terrain/granite_door1.png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1, add_mos={{image="terrain/padlock2.png", display_y=0.1}}}}}
newEntity{ base = "LOCK", define_as = "LOCK_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_vert.png", z=17}, class.new{image="terrain/granite_door1_vert_north.png", z=18, display_y=-1, add_mos={{image="terrain/padlock2.png", display_x=0.2, display_y=-0.4}}}}}

newEntity{
	define_as = "PENTAGRAM",
	name = "demonic symbol",
	image = "terrain/marble_floor.png", add_mos = {{image="terrain/floor_pentagram.png"}},
	display = ';', color=colors.RED, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
}
