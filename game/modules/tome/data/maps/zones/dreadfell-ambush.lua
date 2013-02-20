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

defineTile('.', "GRASS")
defineTile('#', "TREE")
defineTile('u', "GRASS", nil, "UKRUK")
defineTile('o', "GRASS", nil, "HILL_ORC_WARRIOR")
defineTile('O', "GRASS", nil, "HILL_ORC_ARCHER")

startx = 3
starty = 1

return {
[[##################]],
[[###....##.O#######]],
[[##...ooo......####]],
[[#...ouoo......O###]],
[[#..oooo....O...###]],
[[#O..o..........###]],
[[#......O.......###]],
[[#.O.............##]],
[[##..#......#...###]],
[[#######...########]],
[[##################]],
}
