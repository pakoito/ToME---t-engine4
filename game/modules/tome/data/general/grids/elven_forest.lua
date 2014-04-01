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

local grass_editer = { method="borders_def", def="grass"}
local autumn_grass_editer = { method="borders_def", def="autumn_grass"}
local snowy_grass_editer = { method="borders_def", def="snowy_grass"}

local treesdef = {
	{"elventree", {tall=-1, "shadow", "trunk", "foliage_summer"}},
	{"elventree_03", {tall=-1, "shadow", "trunk", "foliage_summer"}},
	{"fat_elventree", {tall=-1, "shadow", "trunk", {"foliage_summer_%02d",1,2}}},
	{"oak", {tall=-1, "shadow", {"trunk_%02d",1,2}, {"foliage_summer_%02d",1,4}}},
}

newEntity{
	define_as = "ELVEN_TREE",
	type = "wall", subtype = "grass",
	name = "tree",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "GRASS",
	nice_tiler = { method="replace", base={"ELVEN_TREE", 100, 1, 30}},
	nice_editer = grass_editer,
}
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="ELVEN_TREE", define_as = "ELVEN_TREE"..i, image = "terrain/grass/grass_main_01.png"}, treesdef))
end

newEntity{
	define_as = "HARDELVEN_TREE",
	type = "wall", subtype = "grass",
	name = "tall thick tree",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	nice_tiler = { method="replace", base={"HARDELVEN_TREE", 100, 1, 30}},
	nice_editer = grass_editer,
}
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="HARDELVEN_TREE", define_as = "HARDELVEN_TREE"..i, image = "terrain/grass/grass_main_01.png"}, treesdef))
end


local snow_treesdef = {
	{"elventree", {tall=-1, "shadow", "trunk", "foliage_winter"}},
	{"fat_elventree", {tall=-1, "shadow", "trunk", "foliage_winter"}},
	{"oak", {tall=-1, "shadow", {"trunk_%02d",1,2}, {"foliage_winter_%02d",1,2}}},
}

newEntity{
	define_as = "SNOW_ELVEN_TREE",
	type = "wall", subtype = "snowy_grass",
	name = "tree",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "GRASS",
	nice_tiler = { method="replace", base={"SNOW_ELVEN_TREE", 100, 1, 30}},
	nice_editer = snowy_grass_editer,
}
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="SNOW_ELVEN_TREE", define_as = "SNOW_ELVEN_TREE"..i, image = "terrain/grass/snowy_grass_main_01.png"}, snow_treesdef))
end

local autumn_treesdef = {
	{"elventree", {tall=-1, "shadow", "trunk", "foliage_autumn"}},
	{"fat_elventree", {tall=-1, "shadow", "trunk", {"foliage_autumn_%02d",1,2}}},
	{"oak", {tall=-1, "shadow", {"trunk_%02d",1,2}, {"foliage_autumn_%02d",1,4}}},
}

newEntity{
	define_as = "AUTUMN_ELVEN_TREE",
	type = "wall", subtype = "autumn_grass",
	name = "tree",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "AUTUMN_GRASS",
	nice_tiler = { method="replace", base={"AUTUMN_ELVEN_TREE", 100, 1, 30}},
	nice_editer = autumn_grass_editer,
}
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="AUTUMN_ELVEN_TREE", define_as = "AUTUMN_ELVEN_TREE"..i, image = "terrain/grass/autumn_grass_main_01.png"}, autumn_treesdef))
end
