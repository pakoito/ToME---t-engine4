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

load("/data/general/grids/basic.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/slime.lua")

newEntity{
	define_as = "ORB_DRAGON",
	name = "orb pedestral (dragon)", image = "terrain/orb_pedestral.png",
	display = '_', color_r=255, color_g=255, color_b=255, back_color=colors.LIGHT_RED,
}
newEntity{
	define_as = "ORB_UNDEATH",
	name = "orb pedestral (undeath)", image = "terrain/orb_pedestral.png",
	display = '_', color_r=255, color_g=255, color_b=255, back_color=colors.LIGHT_RED,
}
newEntity{
	define_as = "ORB_ELEMENTS",
	name = "orb pedestral (elements)", image = "terrain/orb_pedestral.png",
	display = '_', color_r=255, color_g=255, color_b=255, back_color=colors.LIGHT_RED,
}
newEntity{
	define_as = "ORB_DESTRUCTION",
	name = "orb pedestral (destruction)", image = "terrain/orb_pedestral.png",
	display = '_', color_r=255, color_g=255, color_b=255, back_color=colors.LIGHT_RED,
}

newEntity{
	define_as = "PEAK_DOOR",
	name = "sealed door", image = "terrain/granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
}

newEntity{
	define_as = "PEAK_STAIR",
	always_remember = true,
	show_tooltip=true,
	name="Entrance to the High Peak",
	display='>', color=colors.VIOLET, image = "terrain/stair_up_wild.png",
	notice = true,
	change_level=1, change_zone="high-peak",
}

newEntity{
	define_as = "UP_GRUSHNAK",
	name = "exit to Grushnak Pride", image = "terrain/slime_floor.png", add_displays = {class.new{image="terrain/ladder_up.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 5,
	change_zone = "grushnak-pride",
	force_down = true,
}
