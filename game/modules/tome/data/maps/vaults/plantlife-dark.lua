-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

setStatusAll{no_teleport=true}

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

defineTile('.', "GRASS_DARK1")
defineTile('#', {"TREE_DARK1","TREE_DARK2","TREE_DARK3","TREE_DARK4","TREE_DARK5","TREE_DARK6","TREE_DARK7","TREE_DARK8","TREE_DARK9","TREE_DARK10","TREE_DARK11","TREE_DARK12","TREE_DARK13","TREE_DARK14","TREE_DARK15","TREE_DARK16","TREE_DARK17","TREE_DARK18","TREE_DARK19","TREE_DARK20"})
defineTile('X', {"HARDTREE_DARK1","HARDTREE_DARK2","HARDTREE_DARK3","HARDTREE_DARK4","HARDTREE_DARK5","HARDTREE_DARK6","HARDTREE_DARK7","HARDTREE_DARK8","HARDTREE_DARK9","HARDTREE_DARK10","HARDTREE_DARK11","HARDTREE_DARK12","HARDTREE_DARK13","HARDTREE_DARK14","HARDTREE_DARK15","HARDTREE_DARK16","HARDTREE_DARK17","HARDTREE_DARK18","HARDTREE_DARK19","HARDTREE_DARK20"})
defineTile('!', "ROCK_VAULT")

defineTile('V', "GRASS_DARK1", nil, {random_filter={name="poison ivy"}})
defineTile('H', "GRASS_DARK1", {random_filter={add_levels=5, tome_mod="vault"}}, {random_filter={name="treant", add_levels=3}})

startx = 4
starty = 6

return {
[[#XXXXXXX#]],
[[XXV...VXX]],
[[XV.VVV.VX]],
[[X..VHV..X]],
[[XV.VVV.VX]],
[[XXV...VXX]],
[[#XXX!XXX#]],
}
