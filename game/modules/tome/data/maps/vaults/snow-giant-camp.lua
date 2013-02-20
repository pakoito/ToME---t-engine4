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

-- Snow Giant Camp
setStatusAll{no_teleport=true}
rotates = {"default", "90", "180", "270", "flipx", "flipy"}

defineTile('.', "FLOOR")
defineTile(',', "ROCKY_GROUND")
defineTile('#', "HARDWALL")
defineTile('X', "MOUNTAIN_WALL")
defineTile('+', "DOOR")
defineTile('!', "DOOR_VAULT")

defineTile('$', "FLOOR", {random_filter={add_levels=10, tome_mod="vault"}})
defineTile('?', "FLOOR", {random_filter={add_levels=5, tome_mod="vault"}}, {random_filter={add_levels=5, type="giant", subtype="ice"}})
defineTile('P', "ROCKY_GROUND", nil, {random_filter={name="snow giant"}})
defineTile('T', "FLOOR", nil, {random_filter={add_levels=5, name="snow giant thunderer"}})
defineTile('B', "FLOOR", nil, {random_filter={add_levels=5, name="snow giant boulder thrower"}})
defineTile('C', "FLOOR", nil, {random_filter={add_levels=8, name="snow giant chieftain"}})
defineTile('M', "FLOOR", nil, {random_filter={add_levels=8, name="snow giant chieftain", random_boss={nb_classes=1, rank=3.5, loot_quantity = 2}}})

startx = 12
starty = 19

return {
[[XX###############XXXXXXXX]],
[[X,#...#$$$$$#...#XXXXXXXX]],
[[X,#.....CMC.....#,,XXXXXX]],
[[X,#BB.#.....#.TT#,,,,XXXX]],
[[X,#####..C..#####,,,,,,XX]],
[[X,,,,,###!###,,,,,,,,,,XX]],
[[X,#,,,,,,,,,,,,,,###,,,XX]],
[[X###,,,,,,,,,,,,##?##,,,X]],
[[X#?+,,,,,,,,,P,,,#+#,,,,X]],
[[X###,,#,,,,P,,,,,,,,,,,,X]],
[[X,#,,###,,,,,,P,,,,,#,,,X]],
[[X,,,,#?+,,P,,,,,,,,###,,X]],
[[X,,,,###,,,,P,,,,,,+?#,,X]],
[[X,,,,,#,,,,,,,,,,,,###,,X]],
[[XX,,,,,,,,,,,,,,,,,,#,,XX]],
[[XX,,,,#+#,,,,,,,,,,,,,,XX]],
[[XXX,,##?##,,,,,,,,,,,,XXX]],
[[XXXXXX###,,,,,,,,,,,,XXXX]],
[[XXXXXXXXXX,,,,,,,XXXXXXXX]],
[[XXXXXXXXXXXX,XXXXXXXXXXXX]],
}
