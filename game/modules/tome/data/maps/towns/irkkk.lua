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

startx = 49
starty = 47
endx = 49
endy = 47

-- defineTile section
defineTile("#", "BAMBOO_HUT_WALL")
defineTile("+", "BAMBOO_HUT_DOOR")
defineTile("~", "DEEP_WATER")
defineTile("<", "JUNGLE_GRASS_UP_WILDERNESS")
defineTile("_", "BAMBOO_HUT_FLOOR")
defineTile(".", "JUNGLE_GRASS")
defineTile("t", "JUNGLE_TREE")
defineTile("*", "BAMBOO_HUT_COOKING3")

defineTile("1", "BAMBOO_HUT_FLOOR", nil, "YEEK_STORE_GEM")
defineTile("2", "BAMBOO_HUT_FLOOR", nil, "YEEK_STORE_2HANDS")
defineTile("3", "BAMBOO_HUT_FLOOR", nil, "YEEK_STORE_CLOTH")
defineTile("4", "BAMBOO_HUT_FLOOR", nil, "YEEK_STORE_1HAND")
defineTile("5", "BAMBOO_HUT_FLOOR", nil, "YEEK_STORE_LEATHER")
defineTile("6", "BAMBOO_HUT_FLOOR", nil, "YEEK_STORE_NATURE")

-- addSpot section

-- addZone section

-- ASCII map section
return [[
~~~~....................t..........ttttttttt......
~~~..tttt..........tt...t..................t...tt.
~~~...tt..........ttt....t..t....tt...........tt..
~~~.....................tttttt....tttttttttt.ttt..
~~~..........ttt.........ttttttt.ttt....t...tt..t.
~~~.........tttt.###.tt...ttt......ttt..........t.
~~~.........tttt.#_#.tt.........t........t..t.....
~~~..........tt..#_#.ttttt........t.......ttt..t..
~~~.t........t...#_#..tt.tt...ttttt.......t...t...
~~~.t...###......###..ttt...tt....t.tt...tt...t...
~~~~.t..#_#...........t..t..t....t.......tt...t...
~~~~..t.###...........t.t.tt.....tttt...t.t...t...
t~~~~.t..................t..tt...t..t.tt..t..t.t..
~~~~~.....ttt....t........tt.ttt.t...tt...t..t.t..
~~~~~.....t.............t.............t...t....t..
~~~~~.............tt........#####.t.t..tt.t.t..t..
~~~~~~....t.......t....t....#___#.tt.t.tt...t..t..
~~~~~~....t.....ttt.........#_4_#...tt.....tt...t.
~tt~~~....t.t...tt..........#___#.t..tt....tt...t.
~tt~~~......t...t...........##+##....t.tt..tt.t.t.
~~~~~~............tt..................t.....t.t.t.
~~~~~....tt...........................t...t.t.t.tt
~~~~~......................____.......t..ttt.t..tt
~~~~~.....................__1___.......ttt.t.t..t.
~~~~~.....###..#####.....________.....tt.ttttt.tt.
~~~~~.....#_#..#_6_###...___**___......tt.tt.ttt..
~~~~~~....#_####_5___+...___**___.......tt..ttt...
~~~~~~....#________###...________.......tt...ttt..
~~~~~~....#___######......______.............tttt.
~t~~~~~...#_###............____..............t.tt.
~~~~~~~...###..............................t.t..t.
~~~~~~~..................................tt.tt..t.
~~~~~~~.....................#+##..........t.ttt...
~~~~~~......t...............#__#..........t.ttt..t
~~~~~~....tt................#__#..........t.t.tt.t
~~t~~~....t...t..........####__####...........tt..
~~~~~~....t...t..........#__2__3__#..........t.t.t
~~~~~~.......t...........#________#........t.t.t.t
~~~~~~...................####__####........t...t.t
~~~~~~......................#__#............t..ttt
~~~~~....#####..............#__#...............tt.
~~~~~....#___#..............####.............t.tt.
~~~~~~...#___#...............................t..tt
~~~~~~~..###_#..............................tt..t.
~~~~~~~....#_#...............................t..t.
~~~~~~~~...###......tt........#####...............
~t~~~~~~............t..t......#___#...............
~~~~~~~~~..........t...t......#___#..............<
~~~~t~~~~~.........tt.........#####..........tt..t
~~~~~~~~~~~~~...........t................t..t...t.]]
