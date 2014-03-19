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

setStatusAll{no_teleport=true, vault_only_door_open=true}

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

defineTile('.', "FLOOR")
defineTile(',', "GRASS")
defineTile('#', "WALL")
defineTile('X', "HARDWALL")
defineTile('+', "DOOR")
defineTile('!', "DOOR_VAULT")

defineTile('p', "FLOOR", nil, {random_filter={name="rogue", add_levels=3}})
defineTile('P', "FLOOR", nil, {random_filter={name="bandit", add_levels=5}})

defineTile('&', "FLOOR", {random_filter={type="scroll"}})
defineTile('$', "FLOOR", "MONEY_SMALL")
defineTile('*', "FLOOR", {random_filter={type="gem"}})

startx = 10
starty = 0

return {
[[,,,,,,,,,,,,,,]],
[[,XXXXXXX,,,,,,]],
[[,X*#$$$X,,,,,,]],
[[,X*#$$$X,,,,,,]],
[[,X*#$$$X,,,,,,]],
[[,XXXX+XX#!###,]],
[[,#..#.#.....#,]],
[[,#.p+.#.p.p.#,]],
[[,####.#..P..#,]],
[[,#P.#.#.p.p.#,]],
[[,#&.+.+.....#,]],
[[,############,]],
[[,,,,,,,,,,,,,,]],
}