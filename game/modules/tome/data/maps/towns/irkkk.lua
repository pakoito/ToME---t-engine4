-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

startx = 0
starty = 40
endx = 0
endy = 40

-- defineTile section
defineTile("#", "BAMBOO_HUT_WALL")
defineTile("+", "BAMBOO_HUT_DOOR")
defineTile("~", "DEEP_WATER")
defineTile("<", "JUNGLE_GRASS_UP_WILDERNESS")
defineTile("_", "BAMBOO_HUT_FLOOR")
defineTile(".", "JUNGLE_GRASS")
defineTile("t", "JUNGLE_TREE")
defineTile("*", "BAMBOO_HUT_COOKING3")

--defineTile("1", "HARDWALL", nil, nil, "CLOTH_ARMOR_STORE")
--defineTile("2", "HARDWALL", nil, nil, "LIGHT_ARMOR_STORE")
--defineTile("3", "HARDWALL", nil, nil, "STAFF_WEAPON_STORE")
--defineTile("4", "HARDWALL", nil, nil, "SWORD_WEAPON_STORE")
--defineTile("5", "HARDWALL", nil, nil, "RUNEMASTER")
--defineTile("a", "HARDWALL", nil, nil, "ALCHEMIST")

-- addSpot section

-- addZone section

-- ASCII map section
return [[
~~~~....................t..........ttttttttt......
~~~................tt...t..................t...tt.
~~~...............ttt....t..t....tt...........tt..
~~~.....................tttttt....tttttttttt.ttt..
~~~..........ttt.........ttttttt.ttt....t...tt..t.
~~~.........tttt.....tt...ttt......ttt..........t.
~~~.........tttt.....tt.........t........t..t.....
~~~..........tt......ttttt........t.......ttt..t..
~~~..........t........tt.tt...ttttt.......t...t...
~~~...................ttt...tt....t.tt...tt...t...
~~~~..................t..t..t....t.......tt...t...
~~~~..................t.t.tt.....tttt...t.t...t...
~~~~~....................t..tt...t..t.tt..t..t.t..
~~~~~............t........tt.ttt.t...tt...t..t.t..
~~~~~......................t...ttt....t...t....t..
~~~~~.............tt........#####tt.t..tt.t.t..t..
~~~~~~............t.........#___#.tt.t.tt...t..t..
~~~~~~..........ttt.........#___#...tt.....tt...t.
~~~~~~..........tt..........#___#.t..tt....tt...t.
~~~~~~..........t...........##+##t...t.tt..tt.t.t.
~~~~~~............tt..................t.....t.t.t.
~~~~~.................................t...t.t.t.tt
~~~~~......................____.......t..ttt.t..tt
~~~~~.....................______.......ttt.t.t..t.
~~~~~.....###..#####.....________.....tt.ttttt.tt.
~~~~~.....#_#..#___###...___**___......tt.tt.ttt..
~~~~~~....#_####_____+...___**___.......tt..ttt...
~~~~~~....#________###...________.......tt...ttt..
~~~~~~....#___######......______.............tttt.
~~~~~~~...#_###............____..............t.tt.
~~~~~~~...###..............................t.t..t.
~~~~~~~..................................tt.tt..t.
~~~~~~~.....................#+##..........t.ttt...
~~~~~~......................#__#..........t.ttt..t
~~~~~~......................#__#..........t.t.tt.t
~~~~~~...................####__####...........tt..
~~~~~~...................#________#..........t.t.t
~~~~~~...................#________#........t.t.t.t
~~~~~~...................####__####........t...t.t
~~~~~~......................#__#............t..ttt
~~~~~.......................#__#...............tt.
~~~~~.......................####.............t.tt.
~~~~~~.......................................t..tt
~~~~~~~.....................................tt..t.
~~~~~~~......................................t..t.
~~~~~~~~....................................tt.tt.
~~~~~~~~.....................................t....
~~~~~~~~~........................................t
~~~~~~~~~~..................................t....t
~~~~~~~~~~~~~...................................t.]]
