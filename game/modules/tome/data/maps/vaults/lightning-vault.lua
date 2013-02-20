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

setStatusAll{no_teleport=true}

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

startx = 8
starty = 16

defineTile('.', "FLOOR")
defineTile('X', "HARDWALL")
defineTile('#', "WALL")
defineTile('!', "DOOR_VAULT")
defineTile('^', "FLOOR", nil, nil, {random_filter={add_levels=5}})

defineTile('P', "FLOOR", nil, {random_filter={name="snow giant thunderer", add_levels=10}})
defineTile('T', "FLOOR", nil, {random_filter={name="mountain troll thunderer", add_levels=10}})
defineTile('e', "FLOOR", nil, {random_filter={name="greater gwelgoroth", add_levels=10}})
defineTile('E', "FLOOR", nil, {random_filter={name="ultimate gwelgoroth", add_levels=15}})
defineTile('D', "FLOOR", nil, {random_filter={name="storm wyrm", add_levels=20}})

defineTile('$', "FLOOR", "MONEY_BIG")
defineTile('1', "FLOOR", {random_filter={add_levels=15, tome_mod="gvault"}})
defineTile('2', "FLOOR", {random_filter={type="ammo", add_levels=10, tome_mod="vault"}})

return {
[[XXXXXXXXXXXXXXXXX]],
[[XE$..#.....#..$EX]],
[[X$2$##..P..##$2$X]],
[[X.$##.......##$.X]],
[[X.##...X^X...##.X]],
[[X##..e.X.X.e..##X]],
[[X......X#X......X]],
[[X...XXX111XXX...X]],
[[X.T.^.#1D1#.^.T.X]],
[[X...XXX111XXX...X]],
[[X......X#X......X]],
[[X##..e.X.X.e..##X]],
[[X.##...X^X...##.X]],
[[X.$##.......##$.X]],
[[X$2$##..P..##$2$X]],
[[XE$..#.....#..$EX]],
[[XXXXXXXX!XXXXXXXX]],
}
