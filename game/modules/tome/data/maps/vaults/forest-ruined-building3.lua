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

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

defineTile('.', "FLOOR")
defineTile(',', "GRASS")
defineTile(';', "FLOWER")
defineTile('~', "DEEP_WATER")
defineTile('#', "WALL")
defineTile('X', "TREE")
defineTile('+', "DOOR")
defineTile('x', "DOOR_VAULT")

defineTile('s', "FLOOR", nil, {random_filter={name="degenerated skeleton warrior"}})

return {
[[,,,,,,,,,,,,,,,,]],
[[,#X#########X,,,]],
[[,,.+....+..,..X,]],
[[,###....#.###.,,]],
[[,#.+....#.....#,]],
[[,###....###+###,]],
[[,#sx....#,,,,,,,]],
[[,###...X#,;;;;;,]],
[[,#.+..,.,,;~~~;,]],
[[,#####X,,,;;;;;,]],
[[,,,,,,,,,,,,,,,,]],
}
