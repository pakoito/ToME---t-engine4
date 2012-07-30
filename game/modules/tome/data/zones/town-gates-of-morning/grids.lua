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
load("/data/general/grids/mountain.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/sand.lua")

newEntity{ base = "FLOOR", define_as = "ROAD",
	name="cobblestone road",
	display='.', image="terrain/stone_road1.png",
	special_minimap = colors.DARK_GREY,
}

newEntity{
	define_as = "WEST_PORTAL",
	name = "Farportal: Last Hope",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/marble_floor.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[A farportal is a way to travel incredible distances in the blink of an eye. They usually require an external item to use. You have no idea if it is even two-way.
This one seems to go near the town of Last Hope in Maj'Eyal.]],

	orb_portal = {
		change_level = 1,
		change_zone = "wilderness",
		change_wilderness = {
			spot = {type="farportal-end", subtype="last-hope"},
		},
		message = "#VIOLET#You enter the swirling portal and in the blink of an eye you set foot on the outskirts of Last Hope, with no trace of the portal...",
		on_use = function(self, who)
		end,
	},
}
newEntity{ base = "WEST_PORTAL", define_as = "CWEST_PORTAL",
	image = "terrain/marble_floor.png",
	add_displays = {class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3}},
	on_added = function(self, level, x, y)
		level.map:particleEmitter(x, y, 3, "farportal_vortex")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
	end,
}

local gold_mountain_editer = {method="borders_def", def="gold_mountain"}
newEntity{
	define_as = "GOLDEN_MOUNTAIN",
	type = "rockwall", subtype = "grass",
	name = "Sunwall mountain", image = "terrain/golden_mountain5_1.png",
	display = '#', color=colors.GOLD, back_color={r=44,g=95,b=43},
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	air_level = -20,
	nice_editer = gold_mountain_editer,
	nice_tiler = { method="replace", base={"GOLDEN_MOUNTAIN_WALL", 70, 1, 6} },
}
for i = 1, 6 do newEntity{ base="GOLDEN_MOUNTAIN", define_as = "GOLDEN_MOUNTAIN_WALL"..i, image = "terrain/golden_mountain5_"..i..".png"} end

newEntity{ define_as = "FENS",
	name = "Way into the Slazish fens",
	display = '>', color = colors.YELLOW,
	image="terrain/marble_floor.png", add_displays = {class.new{image="terrain/golden_cave_entrance02.png", z=8}},
	change_zone="slazish-fen", change_level = 1,
}
