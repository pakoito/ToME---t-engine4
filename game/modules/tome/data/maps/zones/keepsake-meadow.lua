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

-- defineTile section
defineTile(".", "GRASS")
defineTile("t", "HARDTREE")
defineTile("=", "STEW")
defineTile("*", "FLOWER")
defineTile('~', "DEEP_WATER")
defineTile("<", "GRASS_UP_WILDERNESS")
defineTile("m", "GRASS_MEADOW")
defineTile("d", "GRASS_DREAM")

startx = 1
starty = 11

-- addSpot section
addSpot({13, 3}, "level", "down")
addSpot({9, 10}, "companions", "wardog")
addSpot({15, 10}, "companions", "wardog")
addSpot({9, 11}, "companions", "warrior")
addSpot({14, 12}, "companions", "warrior")
addSpot({4, 10}, "companions", "archer")
addSpot({11, 14}, "companions", "archer")

-- addZone section

-- ASCII map section
return [[
tttttttttttttttttttttttt
tttttttttttttttttttttttt
tttttttttttttttttttttttt
tttttttttttttttttttttttt
ttttttttttt....ttttttttt
ttttttttt.*.~~.*..tttttt
ttttttt....~~~~~~.*.tttt
tttttt.**..~~~~~...ttttt
tttttttddd...*.*..tttttt
tttttt.*.d.*........tttt
ttttt..*.d...*..**...ttt
t<..m....d.=..*.*...tttt
ttttm*...d**.....*.ttttt
ttttt.*.*d....**....tttt
tttttddddd..*..**...tttt
tttttt.*...**.....tttttt
ttttttt...tt..*..ttttttt
ttttttttttttt...tttttttt
tttttttttttttttttttttttt
tttttttttttttttttttttttt
tttttttttttttttttttttttt
tttttttttttttttttttttttt
tttttttttttttttttttttttt
tttttttttttttttttttttttt]]
