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
rotates = {"default", "90", "180", "270", "flipx", "flipy"}

defineTile('.', "FLOOR")
defineTile('~', "DEEP_WATER")
defineTile('#', "HARDWALL")
defineTile('%', "WALL")
defineTile('+', "DOOR")
defineTile('X', "DOOR_VAULT")
defineTile('$', "FLOOR", {random_filter={add_levels=15, tome_mod="vault"}}, {random_filter={add_levels=15, name="dreadmaster"}})
--the above is a floor tile with a +15 level guaranteed ego and a +15 level dreadmaster?
defineTile('\\', "FLOOR", {random_filter={subtype="staff", tome_mod="vault", add_levels=5}}, nil)
--the above is a floor tile with a staff and no monster?
defineTile('(', "FLOOR", {random_filter={subtype="cloth", tome_mod="uvault", add_levels=5}}, nil)
--robe with no monster?
defineTile('o', "FLOOR", nil, {random_filter={subtype="orc", add_levels=5}})
--floor tile with no object and a random +5 level orc from npcs/orc.lua?
defineTile('O', "FLOOR", nil, {random_filter={add_levels=15, name="orc necromancer"}})
--floor tile with no object and an +15 level orc necromancer?
defineTile('K', "FLOOR", nil, {random_filter={add_levels=5, type="undead", subtype="giant", special_rarity="bonegiant_rarity"}})
--floor tile with no object and a random +5 level bone giant from npcs/bone-giant.lua


return {
[[...............................]],
[[.#############################.]],
[[.#...................+...+.K\#.]],
[[.#.......o....o......#####.o\#.]],
[[.#......................K#.K\#.]],
[[.#.....o.................#####.]],
[[.#~~~.....o...###........#o.K#.]],
[[.#~O~..o......%$#........+...X.]],
[[.#~~~.........###........#o.K#.]],
[[.#.......o..o............#####.]],
[[.#......................K#.K(#.]],
[[.#....o....o.........#####.o(#.]],
[[.#...................+...+.K(#.]],
[[.#############################.]],
[[...............................]],
}
