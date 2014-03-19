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

startx = 34
starty = 3
endx = 6
endy = 43

-- defineTile section
defineTile(">", "DEEP_BELLOW")
defineTile("#", "HARDWALL")
defineTile("&", {"CRYSTAL_WALL","CRYSTAL_WALL2","CRYSTAL_WALL3","CRYSTAL_WALL4","CRYSTAL_WALL5","CRYSTAL_WALL6","CRYSTAL_WALL7","CRYSTAL_WALL8","CRYSTAL_WALL9","CRYSTAL_WALL10","CRYSTAL_WALL11","CRYSTAL_WALL12","CRYSTAL_WALL13","CRYSTAL_WALL14","CRYSTAL_WALL15","CRYSTAL_WALL16","CRYSTAL_WALL17","CRYSTAL_WALL18","CRYSTAL_WALL19","CRYSTAL_WALL20",})
defineTile("<", "UP_WILDERNESS")
defineTile(".", "OLD_FLOOR")
defineTile("R", "ESCAPE_REKNOR")

defineTile("A", "STATUE1")
defineTile("B", "STATUE2")
defineTile("C", "STATUE3")
defineTile("D", "STATUE4")
defineTile("E", "STATUE5")
defineTile("F", "STATUE6")

defineTile("1", "HARDWALL", nil, nil, "HEAVY_ARMOR_STORE")
defineTile("2", "HARDWALL", nil, nil, "LIGHT_ARMOR_STORE")
defineTile("7", "HARDWALL", nil, nil, "CLOTH_ARMOR_STORE")
defineTile("3", "HARDWALL", nil, nil, "AXE_WEAPON_STORE")
defineTile("4", "HARDWALL", nil, nil, "MACE_WEAPON_STORE")
defineTile("6", "HARDWALL", nil, nil, "SWORD_WEAPON_STORE")
defineTile("5", "HARDWALL", nil, nil, "RUNIC_STORE")
defineTile("9", "HARDWALL", nil, nil, "GEM_STORE")

-- addSpot section

-- addZone section

-- ASCII map section
return [[
##################################################
##################################################
##################################################
###############>##################R###############
########................##...............#########
######..................##.................#######
#####...................##..................######
#####..................####..................#####
####.......####.......######.....####........#####
####.......####.......######.....####.........####
####.......####.......######.....####.........####
####........#1#.......2###3#.....#4#..........####
####....................##....................####
####...###............................###.....####
####...####..........................####.....####
####...####..........................####.....####
####...##7#..........................#6##.....####
####..........................................####
####...................A..A...................####
####..........................................####
####..........................................####
####..........................................####
####....................&&....................####
####.....####.....F....&&&&....B......####....####
##############........&&&&&&.........#############
##############........&&&&&&.........#############
####.....####.....E....&&&&....C......9#5#....####
####....................&&....................####
####..........................................####
####..........................................####
####................................####......####
####.....####..........D..D.........####......####
####.....####.......................####......####
####.....####........................###......####
####.....###....................###...........####
####..........###...............####..........####
####.........####...............####..........####
####.........####.......##......####..........####
####.........####.....######..................####
####..................######..................####
####..................######..................####
#####.................######.................#####
#####..................####..................#####
######<.................##..................######
#######.................##.................#######
#########...............##...............#########
##################################################
##################################################
##################################################
##################################################]]
