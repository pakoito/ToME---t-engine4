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

--demon nest 3
startx = 0
starty = 10

setStatusAll{no_teleport=true}
rotates = {"default", "90", "180", "270", "flipx", "flipy"}
defineTile('%', "WALL")
defineTile('#', "HARDWALL")
defineTile('+', "DOOR")
defineTile('X', "DOOR_VAULT")
defineTile('.', "LAVA_FLOOR")
defineTile('-', "FLOOR")
defineTile('$', "LAVA_FLOOR", {random_filter={add_levels=25, type="money"}})
defineTile('*', "LAVA_FLOOR", {random_filter={type="gem"}})
defineTile('/', "LAVA_FLOOR", {random_filter={add_levels=10, tome_mod="vault"}})
defineTile('L', "LAVA_FLOOR", {random_filter={add_levels=25, tome_mod="gvault"}})
defineTile('^', "FLOOR", nil, nil, {random_filter={add_levels=20}})
defineTile('u', "LAVA_FLOOR", nil, {random_filter={add_levels=20, type = "demon", subtype = "minor"}})
defineTile('h', "LAVA_FLOOR", nil, {random_filter={add_levels=10, type = "horror", subtype = "eldritch"}})
defineTile('U', "LAVA_FLOOR", {random_filter={add_levels=25, tome_mod="gvault"}}, {random_filter={add_levels=30, type = "demon", subtype = "major"}})
defineTile('D', "LAVA_FLOOR", {random_filter={add_levels=25, tome_mod="gvault"}}, {random_filter={add_levels=30, type = "dragon", subtype = "fire", name = "fire wyrm",}})

return {

[[%%%%%%%%#####%%%%%%%%]],
[[%%%%%%###-%*###%%%%%%]],
[[%%%%###uu-%$*$###%%%%]],
[[%%%##uuuuu%$$$$$##%%%]],
[[%%###%#############%%]],
[[%%#.h^.....h....+.#%%]],
[[%##...h...h.-.h.#.##%]],
[[%#U..-..h....h..#.L#%]],
[[#################-.##]],
[[#.U.$..*/.$../...$.D#]],
[[X.U../$..-*../.$...L#]],
[[#.U.$-*$./.$..*/..$D#]],
[[#################..##]],
[[%#U..h........h.#.L#%]],
[[%##.h...h.-.h...#.##%]],
[[%%#.--h......h..+.#%%]],
[[%%###%#############%%]],
[[%%%##uuuu-%$$$$$##%%%]],
[[%%%%###uuu%$*$###%%%%]],
[[%%%%%%###u%*###%%%%%%]],
[[%%%%%%%%#####%%%%%%%%]],

}