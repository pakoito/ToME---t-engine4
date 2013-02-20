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

--trapped hexagon
startx = 23
starty = 6

setStatusAll{no_teleport=true}
rotates = {"default", "90", "180", "270", "flipx", "flipy"}
defineTile('%', "WALL")
defineTile('.', "FLOOR")
defineTile('#', "HARDWALL")
defineTile('+', "DOOR")
defineTile('X', "DOOR_VAULT")
defineTile('~', "DEEP_WATER")
defineTile('$', "FLOOR", {random_filter={add_levels=25, type="money"}})
defineTile('/', "FLOOR", {random_filter={add_levels=15, tome_mod="gvault"}})
defineTile('^', "FLOOR", nil, nil, {random_filter={add_levels=20}})
defineTile('a', "FLOOR", nil, {random_filter={add_levels=10}})
defineTile('b', "FLOOR", {random_filter={add_levels=10, tome_mod="vault"}}, {random_filter={add_levels=15}})
defineTile('c', "FLOOR", {random_filter={add_levels=15, tome_mod="vault"}}, {random_filter={add_levels=20}})
defineTile('d', "FLOOR", {random_filter={add_levels=15, tome_mod="gvault"}}, {random_filter={add_levels=20}})

return {

[[########################]],
[[#$$a/##.........c##d...#]],
[[#$$a##.........a.a##...#]],
[[#ca##....^^^^^^.c.b%%..#]],
[[#c%%.....^^^^^^.a.a.##.#]],
[[###......^^^^^^c.a.ba###]],
[[##.......^^^/^^.caaa...X]],
[[###......^^^~^^caa.b.###]],
[[#$##.....^~~~^^a..ba##d#]],
[[#$$##....^~^^^^.c.a##..#]],
[[#aaa##............%%...#]],
[[#aacc%%.........c##....#]],
[[########################]],

}