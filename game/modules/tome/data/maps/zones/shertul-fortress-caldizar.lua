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

setStatusAll{no_teleport=true}

startx = 21
starty = 8
stopx = 21
stopy = 8

-- defineTile section
defineTile("#", "SOLID_WALL")
defineTile("=", "OUTERSPACE")
defineTile("F", "CFARPORTAL")
defineTile("&", "FARPORTAL")
defineTile("g", "GLASSWALL")
defineTile("C", "SOLID_FLOOR", nil, "CALDIZAR")
defineTile("+", "SOLID_DOOR")
defineTile(".", "SOLID_FLOOR")
defineTile("*", "COMMAND_ORB")


-- addSpot section

-- addZone section
addZone({2, 2, 14, 14}, "zonename", "Control Room")
addZone({19, 5, 26, 11}, "zonename", "Exploratory Farportal")
addZone({8, 8, 9, 9}, "particle", "house_orbcontrol")

-- ASCII map section
return [[
#########################===============
##########################==============
##...##...##...############=============
##.............############=============
##.............#############============
###...........#####.......##============
###...........#####.......##============
##.............####...&&&..g============
##......*..C.....+....&F&..g============
##.............####...&&&.##============
###...........#####.......##============
###...........#####.......##============
##.............#############============
##.............#############============
##...##...##...#############============
############################============
###########################=============
###########################=============
##########################==============
#########################===============]]
