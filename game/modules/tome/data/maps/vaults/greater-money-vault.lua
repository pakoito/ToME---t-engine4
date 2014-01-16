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

-- Greater money vault

startx = 28
starty = 6

setStatusAll{no_teleport=true}
rotates = {"default", "90", "180", "270", "flipx", "flipy"}

defineTile('.', "FLOOR")
defineTile('#', "HARDWALL")
defineTile('+', "DOOR")
defineTile('X', "DOOR_VAULT")
defineTile('a', "FLOOR", nil, {random_filter={add_levels=10}})
defineTile('b', "FLOOR", {random_filter={add_levels=10, tome_mod="vault"}}, {random_filter={add_levels=15}})
defineTile('c', "FLOOR", {random_filter={add_levels=15, tome_mod="vault"}}, {random_filter={add_levels=20}})
defineTile('d', "FLOOR", {random_filter={add_levels=15, tome_mod="gvault"}}, {random_filter={add_levels=20}})
defineTile('^', "FLOOR", nil, nil, {random_filter={add_levels=20}})
defineTile('$', "FLOOR", {random_filter={add_levels=25, type="money"}})


return {

[[#############################]],
[[#.ba..a..+a..c#.+a...#.+.a.a#]],
[[#c...a...#.c..#.#...a#.#a.a.#]],
[[#+########a..a#.#.a..#.#.a.a#]],
[[#c.a....a#..b.#.#b.a.#.#a.a.#]],
[[#..b..b..#.b..#.#b.b.#.#+####]],
[[########+#..a.+c#b...+.#....X]],
[[#....a.bb#############.#+####]],
[[#.....c..#c.$$$$$$$.c#.#a.a.#]],
[[#+########c.$$$$$$$.c#.#.a.a#]],
[[#aaabcaa^#..$$$$$$$.c#.#a.a.#]],
[[#aaabbaa.+..$$$$$$$.c#.+.a.a#]],
[[#############################]],

}