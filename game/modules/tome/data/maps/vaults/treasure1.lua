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

defineTile(';', "FLOOR", nil, nil, nil, {room_map={special=false, room=false, can_open=true}})
defineTile('.', "FLOOR")
defineTile('#', "HARDWALL")
defineTile('!', "DOOR_VAULT")
defineTile('+', "DOOR")
defineTile('X', "FLOOR", nil, {random_filter={add_levels=15}})
defineTile('$', "FLOOR", {random_filter={add_levels=10, ego_chance=25}})

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

return {
[[;;;;;;;;;;;;;;;;;;;;]],
[[;########!!########;]],
[[;#..#...+XX+...#..#;]],
[[;#..+...#XX#...+..#;]],
[[;##+##.+#++#+.##+##;]],
[[;#...###....###...#;]],
[[;#...+X######X+...#;]],
[[;#.#+#XX+XX+XX#+#.#;]],
[[;#+#X##########.#+#;]],
[[;#.#XXXX#$$#....#X#;]],
[[;#.#XXXX#$$#....#X#;]],
[[;#+#X####++####.#+#;]],
[[;#.#+#..+..+XX#+#.#;]],
[[;#...+.######X+...#;]],
[[;#...###XXXX###...#;]],
[[;##+##X+#++#+.##+##;]],
[[;#XX+XXX#..#...+..#;]],
[[;#XX#XXX+..+...#..#;]],
[[;########!!########;]],
[[;;;;;;;;;;;;;;;;;;;;]],
}