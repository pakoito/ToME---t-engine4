-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
defineTile("#", "HARDWALL")
defineTile("~", "DEEP_WATER")
defineTile("<", "GRASS_UP_WILDERNESS")
defineTile("_", "OLD_FLOOR")
defineTile(".", "GRASS")
defineTile("t", "TREE")

defineTile("1", "HARDWALL", nil, nil, "CLOTH_ARMOR_STORE")
defineTile("2", "HARDWALL", nil, nil, "LIGHT_ARMOR_STORE")
defineTile("3", "HARDWALL", nil, nil, "STAFF_WEAPON_STORE")
defineTile("4", "HARDWALL", nil, nil, "SWORD_WEAPON_STORE")
defineTile("5", "HARDWALL", nil, nil, "RUNEMASTER")
defineTile("7", "HARDWALL", nil, nil, "LIBRARY")
defineTile("a", "HARDWALL", nil, nil, "ALCHEMIST")

-- addSpot section

-- addZone section

-- ASCII map section
return [[
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~###~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~##_##~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~##___##~~~~~~~~t~~~~~~~~~~~~~
~~~~~~~~~~~t~~~~~~~~~##___##~~~~~~~~~~~~~~~~~~~~~~
~~~~~t~~~~~t~~~~~~~~###___###~~~~~~~~~~~~~t~~~~~~~
~~~~~~~~~~~~~~~~~~~~###___###~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~t~~~####___####~~~t~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~####___####~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~t~~~~~~~~~####___####~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~t~~~~~~~~##2##___##3##~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~#___________#..~~~......~~~t~~~~
~~~~~~~~~~~~~~~~~~#___________#............~~~~~~~
~~~~~~~~~~~~~~~~~~#___________#.....tttt...~~~~~~~
~~~~........~~~~~~#___________#.....ttttt.~~~~~~~~
~~~............~~~#___________#......ttttt~~~~~~~~
~~...............##___________##......ttt..~~~~~~~
~~....ttt........#__#########__#...........~~~~~~~
~....ttt.........#_###########_#...........~~~~~~~
~...ttt.....######__#5##a##1#__######.......~~~~~~
~...t....####_______________________####......~~~~
~......###_______#_____..._____#_______###.....~~~
~.....##________###___.....___###________##....~~~
~....##_________###__..ttt..__###_________##...~~~
~....___________###__..ttt..__###___________...~~~
~....##_________###__..ttt..__###_________##...~~~
~~....##________###___.....___###________##.....~~
~~.....###_______#_____..._____#_______###......~~
~~.......####_______________________####........~~
~~..........######__#########__######..........~~~
~~...............#_###########_#...............~~~
~.....t.tt.......#__####4####__#...............~~~
~....ttttt.......##___________##..............~~~~
~....ttttt........#___________#......tt.......~~~~
~~...tttt.....t...#___________#.....tttt.....~~~~~
~~...tt.......t...#___________#....ttttt....~~~~~~
~.............t...#___________#...tttttt....~~~~~~
~.................#___________#...tttt......~~~~~~
~..........tt.t...#####___#####..tttt.......~~~~~~
.....tt....t.......####___#7##...ttt.......~~~~t~~
<...ttt...t....tt..####___#__#.............~~~~~~~
...tttt............####___#_##...........~~~~~~~~~
~..tttt....~~.......###_____#.........~~~~~~~~~~~~
~..tttt....~~.......###___###........~~~~~~~~~~~~~
~~........~~~~.......##___##........~~~~~~~~~~~~~~
~~.......~~~~~~~.....##___##........~~~~~~~~~~~~~~
~~~..~~~~~~~~~~~~.....##_##........~~~~~~~~~~t~~~~
~~~~~~~~~~~~~~~~~~~~~..###.....~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~.......~~~~~~~~~~~t~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]