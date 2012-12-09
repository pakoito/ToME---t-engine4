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

startx = 0
starty = 12
endx = 0
endy = 12

-- defineTile section
defineTile("#", "HARDWALL")
defineTile("*", "COFFIN", nil, nil, nil, nil, {type="coffin", subtype="chamber"})
defineTile("+", "DOOR", nil, nil, nil, nil, {type="door", subtype="chamber"})
defineTile("<", "UP", nil, nil, nil, nil, {type="stairs", subtype="stairs"})
defineTile("_", "ALTAR", nil, nil, nil, {no_teleport=true})
defineTile(";", "FLOOR", nil, nil, nil, {no_teleport=true})
defineTile(".", "FLOOR")
defineTile("@", "FLOOR", nil, "CELIA", nil, {no_teleport=true})
defineTile("L", "FLOOR", "CELIA_NOTE")

-- addSpot section

-- addZone section

-- ASCII map section
return [[
##################################################
##################################################
##################################################
##################################################
##################################################
##################################################
##.*.#.*.#.*.#.*.#.*.#.*.#########################
##...#...#...#...#...#...#########################
##...#...#...#...#...#...#########################
##...#...#...#...#...#...###;;;;;;;;;;;###########
###.###.###.###.###.###.###;;#;;;;_;;#;;##########
###+###+###+###+###+###+###;;;;;_;;;;;;;;#########
<.L.......................+;;;;;;;;@_;;;;;########
###+###+###+###+###+###+###;;;;;_;;;;;;;;#########
###.###.###.###.###.###.###;;#;;;;_;;#;;##########
##...#...#...#...#...#...###;;;;;;;;;;;###########
##...#...#...#...#...#...#########################
##...#...#...#...#...#...#########################
##.*.#.*.#.*.#.*.#.*.#.*.#########################
##################################################
##################################################
##################################################
##################################################
##################################################
##################################################]]