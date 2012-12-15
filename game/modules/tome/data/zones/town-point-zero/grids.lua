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
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/void.lua")
load("/data/general/grids/mountain.lua")

newEntity{
	define_as = "RIFT",
	name = "Temporal Rift to Maj'Eyal", image="terrain/floating_rocks05_01.png", add_mos={{image="terrain/demon_portal2.png"}},
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[The rift leads to Maj'Eyal]],
	change_level = 1,
	change_zone = "wilderness",
}

local ice_editer = {method="borders_def", def="ice"}

newEntity{
	define_as = "COLD_FOREST",
	type = "wall", subtype = "ice",
	name = "cold forest", image = "terrain/tree_dark_snow1.png",
	display = '#', color=colors.WHITE, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_tiler = { method="replace", base={"COLD_FOREST", 100, 1, 30} },
	nice_editer = ice_editer,
}
for i = 1, 30 do
newEntity{ base="COLD_FOREST",
	define_as = "COLD_FOREST"..i,
	image = "terrain/frozen_ground.png",
	add_displays = class:makeTrees("terrain/tree_dark_snow", 13, 10),
	nice_tiler = false,
}
end

newEntity{
	define_as = "POLAR_CAP",
	type = "floor", subtype = "ice",
	name = "polar cap", image = "terrain/frozen_ground.png",
	display = '.', color=colors.LIGHT_BLUE, back_color=colors.WHITE,
	can_encounter=true, equilibrium_level=-10,
	nice_editer = ice_editer,
}
