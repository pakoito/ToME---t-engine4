-- ToME - Tales of Middle-Earth
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

setStatusAll{no_teleport=true}

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

defineTile('.', "FLOOR")
defineTile(',', "GRASS")
defineTile('~', "SHALLOW_WATER")
defineTile('#', "HARDWALL")
defineTile('X', "TREE")
defineTile('+', "DOOR")

defineTile('T', "FLOOR", {random_filter={type="potion"}}, {random_filter={name="forest troll"}})
defineTile('t', "FLOOR", nil, {random_filter={name="forest troll"}})
defineTile('$', "FLOOR", {random_filter={type="potion"}}, nil)

return {
[[,,,,,,,,,,,,,,,,,,,,,,]],
[[,,,XX,,X,,,,,,,,,,X,,,]],
[[,,X~~~~~~~,,~~~~~XXX,,]],
[[,XX~#####~,,~#####~,,,]],
[[,XX~#...#~~~~#...#~,X,]],
[[,XX~#.t.######.t.#~,,,]],
[[,,X~#...#.t..#...#~,X,]],
[[,XX~####+..t.+####~,,,]],
[[,XX~~~#....#####~~~,,,]],
[[,,,..t+....#$$$#~,,,X,]],
[[,,,..t+....+$$T#~,,,x,]],
[[,XX~~~#....#####~~~,X,]],
[[,,X~####+....+####~,X,]],
[[,,X~#...#....#...#~,X,]],
[[,,X~#.t.######.t.#~,,,]],
[[,XX~#...#~~~~#...#~,,,]],
[[,,X~#####~,,~#####~,,,]],
[[,,X~~~~~~~,,~~~~~~~,,,]],
[[,,XXX,X,,XXX,X,,XXX,,,]],
[[,,,,,,,,,,,,,,,,,,,,,,]],
}
