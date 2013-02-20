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

setStatusAll{no_teleport=true, vault_only_door_open=true}

defineTile(';', "FLOOR", nil, nil, nil, {room_map={special=false, room=false, can_open=true}})
defineTile('.', "FLOOR")
defineTile('^', "FLOOR", nil, nil, {random_filter={}})
defineTile('X', "HARDWALL")
defineTile('#', "WALL")
defineTile('!', "DOOR_VAULT")
defineTile('+', "DOOR")
defineTile('o', "FLOOR", nil, {random_filter={add_levels=5}})
defineTile('O', "FLOOR", nil, {random_filter={add_levels=10}})
defineTile('5', "FLOOR", {random_filter={add_levels=10, tome_mod="gvault"}}, {random_filter={}})
defineTile('4', "FLOOR", nil, {random_filter={}})
defineTile('3', "FLOOR", {random_filter={add_levels=5, tome_mod="vault"}}, {random_filter={add_levels=15}})
defineTile('2', "FLOOR", {random_filter={add_levels=20, tome_mod="gvault"}}, {random_filter={add_levels=30}})
defineTile('1', "FLOOR", nil, {random_filter={add_levels=30}})

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

return {
[[;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;]],
[[;.........XXXXXXXXXX.........;]],
[[;....XXXXXXO.O..O.OXXXXXX....;]],
[[;....X..................X....;]],
[[;XXXXX.###.###..###.###.XXXXX;]],
[[;X.....#3#^#1#..#4#^#3#.....X;]],
[[;X.o.X.###.###..###.###.X.o.X;]],
[[;X.o.X..^...^....^...^..X.o.X;]],
[[;X.O...###.###..###.###...O.X;]],
[[;X.O...#4#^#3#..#5#^#2#...O.X;]],
[[;X.o.X.###.###..###.###.X.o.X;]],
[[;X.o.X..................X.o.X;]],
[[;X..........................X;]],
[[;XXXXXXXXXXXXX++XXXXXXXXXXXXX;]],
[[;..X..Xoo...X^oo^X...ooX..X..;]],
[[;..X..X..X..X^oo^X..X..X..X..;]],
[[;..!.....X..........X.....!..;]],
[[;..XXXXXXXXXXXXXXXXXXXXXXXX..;]],
[[;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;]],
}