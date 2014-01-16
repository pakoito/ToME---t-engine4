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
	define_as = "GLADIUM_ORB",
	name = "Gladium Control Orb", image = "terrain/marble_floor.png", add_displays = {class.new{z=18, image="terrain/pedestal_orb_02.png", display_h=2, display_y=-1}},
	display = '*', color=colors.PURPLE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			local chat = require("engine.Chat").new("shertul-fortress-gladium-orb", self, e, {player=e})
			chat:invoke()
		end
		return true
	end,
}

-----------------------------------------
-- Glass Walls
-----------------------------------------
newEntity{
	define_as = "HARDGLASSWALL",
	type = "wall", subtype = "floor",
	name = "glass wall", image = "terrain/hardglasswall.png",
	display = '#', color=colors.AQUAMARINE, back_color=colors.GREY,
	z = 3,
	nice_tiler = { method="wall3d", inner="HARDGLASSWALLF", north="HARDGLASSWALL_NORTH", south="HARDGLASSWALL_SOUTH", north_south="HARDGLASSWALL_NORTH_SOUTH", small_pillar="HARDGLASSWALL_SMALL_PILLAR", pillar_2="HARDGLASSWALL_PILLAR_2", pillar_8="HARDGLASSWALL_PILLAR_8", pillar_4="HARDGLASSWALL_PILLAR_4" },
	always_remember = true,
	does_block_move = true,
	air_level = -20,
}
newEntity{ base = "HARDGLASSWALL", define_as = "HARDGLASSWALLF", image = "terrain/marble_floor.png",add_mos={{image = "terrain/glass/wall_glass_middle_01_64.png"}}}
newEntity{ base = "HARDGLASSWALL", define_as = "HARDGLASSWALL_NORTH", image = "terrain/marble_floor.png",add_mos={{image = "terrain/glass/wall_glass_middle_01_64.png"}}, z = 3, add_displays = {class.new{image="terrain/glass/wall_glass_top_01_64.png", z=18, display_y=-1}}}
newEntity{ base = "HARDGLASSWALL", define_as = "HARDGLASSWALL_NORTH_SOUTH", image = "terrain/marble_floor.png",add_mos={{image = "terrain/glass/wall_glass_01_64.png"}}, z = 3, add_displays = {class.new{image="terrain/glass/wall_glass_top_01_64.png", z=18, display_y=-1}}}
newEntity{ base = "HARDGLASSWALL", define_as = "HARDGLASSWALL_SOUTH", image = "terrain/marble_floor.png",add_mos={{image = "terrain/glass/wall_glass_01_64.png"}}, z = 3}
newEntity{ base = "HARDGLASSWALL_NORTH_SOUTH", define_as = "HARDGLASSWALL_PILLAR_6"}
newEntity{ base = "HARDGLASSWALL_NORTH_SOUTH", define_as = "HARDGLASSWALL_PILLAR_4"}
newEntity{ base = "HARDGLASSWALL_NORTH_SOUTH", define_as = "HARDGLASSWALL_SMALL_PILLAR"}
newEntity{ base = "HARDGLASSWALL_NORTH", define_as = "HARDGLASSWALL_PILLAR_8"}
newEntity{ base = "HARDGLASSWALL_SOUTH", define_as = "HARDGLASSWALL_PILLAR_2"}
