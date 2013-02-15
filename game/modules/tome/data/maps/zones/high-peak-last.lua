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

setStatusAll{control_teleport_fizzle=30}

defineTile('<', "UP")
defineTile(',', "FLOOR")
defineTile('.', "FLOOR", nil, nil, nil, {lite=true})
defineTile('#', "WALL", nil, nil, nil, {lite=true})
defineTile('*', "HARDWALL", nil, nil, nil, {lite=true})

-- Portals
defineTile('&', "FAR_EAST_PORTAL", nil, nil, nil, {lite=true, no_teleport=true})
defineTile('!', "CFAR_EAST_PORTAL", nil, nil, nil, {lite=true, no_teleport=true})
defineTile('"', "WEST_PORTAL", nil, nil, nil, {lite=true, no_teleport=true})
defineTile("'", "CWEST_PORTAL", nil, nil, nil, {lite=true, no_teleport=true})
defineTile('V', "VOID_PORTAL", nil, nil, nil, {lite=true})
defineTile('v', "CVOID_PORTAL", nil, nil, nil, {lite=true})
defineTile('d', "ORB_DESTRUCTION", nil, nil, nil, {lite=true})
defineTile('D', "ORB_DRAGON", nil, nil, nil, {lite=true})
defineTile('E', "ORB_ELEMENTS", nil, nil, nil, {lite=true})
defineTile('U', "ORB_UNDEATH", nil, nil, nil, {lite=true})

-- Bosses
defineTile('A', "FLOOR", nil, "ELANDAR", nil, {lite=true})
defineTile('P', "FLOOR", nil, "ARGONIEL", nil, {lite=true})

addSpot({16, 4}, "portal", "demon")
addSpot({33, 4}, "portal", "dragon")
addSpot({33, 18}, "portal", "undead")
addSpot({16, 18}, "portal", "elemental")

startx = 25
starty = 8
endx = 25
endy = 8

return [[
**************************************************
******************..............******************
************..........................************
***********..............#.............***********
***********.....d.......###......D.....***********
************............###...........************
*************............#...........*************
*************............#...........*************
**************......................**************
**************......................**************
*****"""******..........VVV.........******&&&*****
*****"'"******..#####..AVvVP..####..******&!&*****
*****"""******..........VVV.........******&&&*****
**************......................**************
**************......................**************
*************............#...........*************
*************............#...........*************
************............###...........************
***********.....E.......###......U.....***********
***********..............#.............***********
************..........................************
******************..............******************
**************************************************]]
