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
load("/data/general/grids/mountain.lua")

newEntity{ base = "GRASS", define_as = "FIELDS",
	name="cultivated fields",
	display=';', image="terrain/cultivation.png",
	nice_tiler = { method="replace", base={"FIELDS", 100, 1, 4}},
}
for i = 1, 4 do newEntity{ base = "FIELDS", define_as = "FIELDS"..i, image="terrain/grass.png", add_mos={{image="terrain/cultivation0"..i..".png"}} } end

newEntity{ base = "FLOOR", define_as = "COBBLESTONE",
	name="cobblestone road",
	display='.', image="terrain/stone_road1.png",
	special_minimap = colors.DARK_GREY,
}

newEntity{ base = "FLOOR", define_as = "ROCK",
	name="magical rock",
	image="terrain/grass.png", add_displays = {class.new{image="terrain/maze_rock.png"}},
	does_block_move = true
}

newEntity{ base = "DEEP_WATER", define_as = "FOUNTAIN",
	name="fountain",
	does_block_move = true
}
