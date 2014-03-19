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

--Frost dragon lair

startx = 28
starty = 6

setStatusAll{no_teleport=true}
rotates = {"default", "90", "180", "270", "flipx", "flipy"}

defineTile('.', "FLOOR")
defineTile('#', "HARDWALL")
defineTile('+', "DOOR")
defineTile('X', "DOOR_VAULT")
defineTile('C', "FLOOR", nil, {random_filter={add_levels=10, name = "ice wyrm"}})
defineTile('d', "FLOOR", nil, {random_filter={add_levels=15, name="cold drake hatchling"}})
defineTile('$', "FLOOR", {random_filter={add_levels=15, tome_mod="vault"}})
defineTile('D', "FLOOR", nil, {random_filter={add_levels=10, name = "cold drake"}})


return {

[[#############################]],
[[#C..........................#]],
[[#.....................D.....#]],
[[#..###################+###..#]],
[[#$.#...+.....$#C$$$$$#...#..#]],
[[#$.#...#..ddd$#......#...#..#]],
[[#$.#...#..ddd$#......#...#..X]],
[[#$.#..D#..ddd$#......#...#..#]],
[[#$.#..D#.....$#....DD+...#..#]],
[[#..###+###################..#]],
[[#...........................#]],
[[#C..........................#]],
[[#############################]],

}