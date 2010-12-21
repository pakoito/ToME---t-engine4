-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

startx = 1
starty = 15
stopx = 1
stopy = 15

-- defineTile section
defineTile("#", "OLD_WALL")
defineTile("h", "OLD_FLOOR", nil, "WEIRDLING_BEAST")
defineTile("*", "TELEPORT_OUT")
defineTile("+", "SEALED_DOOR")
defineTile("<", "LAKE_NUR")
defineTile(".", "OLD_FLOOR")

-- addSpot section
addSpot({11, 15}, "door", "weirdling")
addSpot({18, 17}, "portal", "back")
addSpot({1, 15}, "stair", "up")

-- addZone section
addZone({10, 0, 29, 29}, "no-teleport")
addZone({12, 12, 18, 17}, "zonename", "Control Room")
addZone({1, 10, 9, 19}, "zonename", "Storage Room")
addZone({13, 7, 17, 10}, "zonename", "Teleportation Control")

-- ASCII map section
return [[
##############################
#############.....######.....#
#############.....######.....#
#############.....#######...##
#############.....#######.#.##
#############.....#######.#.##
###############+#########.#.##
#############.....#######...##
#############.....#######...##
#############.....#######.#.##
########..###.....#######.#.##
######....#####+#########...##
#####.....##.......#######+###
####..##..##.......#...#.....#
#.........##.......#...#.....#
#<.......h.+.......+...+.....#
####..##..##.......#...#.....#
#####.....##......*#######+###
######....#####+#########...##
########..##.......######.#.##
############.......######.#.##
############...#...######...##
############.......######...##
############.......######.#.##
###############+#########.#.##
#############.....#######.#.##
#############.....#######...##
#############.....######.....#
#############.....######.....#
##############################]]