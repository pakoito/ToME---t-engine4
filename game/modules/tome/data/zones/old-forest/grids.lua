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
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")

local treesdef = {
	{"oldforest_tree_01", {tall=-1, "shadow", "trunk_01", {"foliage_spring_%02d",1,2}}},
	{"oldforest_tree_01", {tall=-1, "shadow", "trunk_02", {"foliage_spring_%02d",3,3}}},
	{"oldforest_tree_01", {tall=-1, "shadow", "trunk_03", {"foliage_spring_%02d",4,4}}},
	{"oldforest_tree_02", {tall=-1, "shadow", "trunk_01", {"foliage_spring_%02d",1,2}}},
	{"oldforest_tree_02", {tall=-1, "shadow", "trunk_02", {"foliage_spring_%02d",3,3}}},
	{"oldforest_tree_02", {tall=-1, "shadow", "trunk_03", {"foliage_spring_%02d",4,4}}},
	{"oldforest_tree_03", {tall=-1, "shadow", "trunk_01", {"foliage_spring_%02d",1,2}}},
	{"oldforest_tree_03", {tall=-1, "shadow", "trunk_02", {"foliage_spring_%02d",3,3}}},
	{"oldforest_tree_03", {tall=-1, "shadow", "trunk_03", {"foliage_spring_%02d",4,4}}},
	{"small_oldforest_tree_01", {"shadow", "trunk_01", {"foliage_spring_%02d",1,2}}},
	{"small_oldforest_tree_01", {"shadow", "trunk_02", {"foliage_spring_%02d",3,3}}},
	{"small_oldforest_tree_01", {"shadow", "trunk_03", {"foliage_spring_%02d",4,4}}},
	{"small_oldforest_tree_02", {"shadow", "trunk_01", {"foliage_spring_%02d",1,2}}},
	{"small_oldforest_tree_02", {"shadow", "trunk_02", {"foliage_spring_%02d",3,3}}},
	{"small_oldforest_tree_02", {"shadow", "trunk_03", {"foliage_spring_%02d",4,4}}},
	{"small_oldforest_tree_03", {"shadow", "trunk_01", {"foliage_spring_%02d",1,2}}},
	{"small_oldforest_tree_03", {"shadow", "trunk_02", {"foliage_spring_%02d",3,3}}},
	{"small_oldforest_tree_03", {"shadow", "trunk_03", {"foliage_spring_%02d",4,4}}},

	{"oldforest_tree_01", {tall=-1, "shadow", "trunk_01", {"foliage_bare_%02d",1,2}}},
	{"oldforest_tree_01", {tall=-1, "shadow", "trunk_02", {"foliage_bare_%02d",3,3}}},
	{"oldforest_tree_01", {tall=-1, "shadow", "trunk_03", {"foliage_bare_%02d",4,4}}},
	{"oldforest_tree_02", {tall=-1, "shadow", "trunk_01", {"foliage_bare_%02d",1,2}}},
	{"oldforest_tree_02", {tall=-1, "shadow", "trunk_02", {"foliage_bare_%02d",3,3}}},
	{"oldforest_tree_02", {tall=-1, "shadow", "trunk_03", {"foliage_bare_%02d",4,4}}},
	{"oldforest_tree_03", {tall=-1, "shadow", "trunk_01", {"foliage_bare_%02d",1,2}}},
	{"oldforest_tree_03", {tall=-1, "shadow", "trunk_02", {"foliage_bare_%02d",3,3}}},
	{"oldforest_tree_03", {tall=-1, "shadow", "trunk_03", {"foliage_bare_%02d",4,4}}},
	{"small_oldforest_tree_01", {"shadow", "trunk_01", {"foliage_bare_%02d",1,2}}},
	{"small_oldforest_tree_01", {"shadow", "trunk_02", {"foliage_bare_%02d",3,3}}},
	{"small_oldforest_tree_01", {"shadow", "trunk_03", {"foliage_bare_%02d",4,4}}},
	{"small_oldforest_tree_02", {"shadow", "trunk_01", {"foliage_bare_%02d",1,2}}},
	{"small_oldforest_tree_02", {"shadow", "trunk_02", {"foliage_bare_%02d",3,3}}},
	{"small_oldforest_tree_02", {"shadow", "trunk_03", {"foliage_bare_%02d",4,4}}},
	{"small_oldforest_tree_03", {"shadow", "trunk_01", {"foliage_bare_%02d",1,2}}},
	{"small_oldforest_tree_03", {"shadow", "trunk_02", {"foliage_bare_%02d",3,3}}},
	{"small_oldforest_tree_03", {"shadow", "trunk_03", {"foliage_bare_%02d",4,4}}},
}

for i = 1, 30 do
	newEntity(class:makeNewTrees({base="TREE", define_as = "TREE"..i, image = "terrain/grass.png"}, treesdef, 3))
end
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="HARDTREE", define_as = "HARDTREE"..i, image = "terrain/grass.png"}, treesdef))
end

newEntity{
	define_as = "LAKE_NUR",
	name = "way to the lake of Nur",
	display = '>', color_r=255, color_g=255, color_b=0, image = "terrain/grass.png", add_displays = {class.new{image = "terrain/way_next_2.png"}},
	notice = true,
	always_remember = true,
	change_level = 1, change_zone = "lake-nur",
}
