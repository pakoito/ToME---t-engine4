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


-- defineTile section
defineTile("#", "MOUNTAIN_WALL")
quickEntity('-', {name='open sky', display=' ', does_block_move=true})
defineTile(">", "DOWN")
defineTile(".", "ROCKY_GROUND")

startx = 16
starty = 5
endx = 10
endy = 14


-- ASCII map section
return [[
-------------------------
-------------------------
---------.....-----------
--------.......---##-----
-----.............#..----
----.##..............----
---..#.....###......-----
---.......#####.....-----
---.......######.....----
----....###########..----
-----...###########...---
----...###########....---
----....#########...#..--
---.....########....##---
---.......>#####......---
----.......##.........---
----.................----
----.##...........-------
----.##.-.......##-------
------.--..-...##.-------
--------..--......-------
------------.....--------
-------------------------
-------------------------
-------------------------]]
