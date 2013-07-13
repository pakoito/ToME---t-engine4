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

load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")

local grass_editer = { method="borders_def", def="grass"}

newEntity{ base = "FLOOR", define_as = "DIRT",
	name="dirt road",
	display='.', image="terrain/stone_road1.png",
	special_minimap = colors.DARK_GREY,
}

newEntity{
	define_as = "STEW",
	type = "wall", subtype = "grass",
	name = "troll stew", image = "terrain/grass.png", add_mos={{image="terrain/troll_stew.png"}},
	display = '~', color=colors.LIGHT_RED, back_color=colors.RED,
	does_block_move = true,
	pass_projectile = true,
	nice_editer = grass_editer,
}

local grass_editer = { method="borders_def", def="grass"}

newEntity{
	define_as = "BOGTREE",
	type = "wall", subtype = "water",
	name = "tree",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color=colors.DARK_BLUE,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "BOGWATER",
	nice_tiler = { method="replace", base={"BOGTREE", 100, 1, 20}},
	shader = "water",
}
for i = 1, 20 do newEntity{ base="BOGTREE", define_as = "BOGTREE"..i, image = "terrain/water_grass_5_1.png", add_displays = class:makeTrees("terrain/tree_alpha", 13, 9)} end

newEntity{ base="WATER_BASE",
	define_as = "BOGWATER",
	name = "bog water",
	image="terrain/water_grass_5_1.png",
}

newEntity{ base="BOGWATER",
	define_as = "BOGWATER_MISC",
	nice_tiler = { method="replace", base={"BOGWATER_MISC", 100, 1, 7}},
}
for i = 1, 7 do newEntity{ base="BOGWATER_MISC", define_as = "BOGWATER_MISC"..i, add_mos={{image="terrain/misc_bog"..i..".png"}}} end
