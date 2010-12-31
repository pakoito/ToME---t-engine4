-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

startx = 28
starty = 0
endx = 29
endy = 45

-- defineTile section
defineTile("#", "WATER_WALL")
defineTile("~", "WATER_FLOOR")
defineTile("*", "WATER_DOOR")
defineTile("<", "OLD_FOREST")
defineTile("-", "GRASS")
defineTile(">", "WATER_DOWN")
defineTile(".", "SAND")
defineTile("T", {"TREE","TREE2","TREE3","TREE4","TREE5","TREE6","TREE7","TREE8","TREE9","TREE10","TREE11","TREE12","TREE13","TREE14","TREE15","TREE16","TREE17","TREE18","TREE19","TREE20"})

-- addSpot section

-- addZone section

-- ASCII map section
return [[
TTTTTTTTTTTTTTTTTTTTTTTTTTTT<TTTTTTTTTTTTTTTTTTTTT
TTTTTTTTTTTTTTTTTTTTTTTTTT---TTTTTTTTTTTTTTTTTTTTT
TTTTTTTTTTTTTTTT......TTTT-TTTTTTTTTTTTTTTTTTTTTTT
TTTTTTTTTTT..T..T....TT.......TTTTTTTTTTTTTTTTTTTT
......TT.......TT..........T........TTTTTTTTTTTTTT
..............T....TT......TTTT.......TTTTTTTTTTTT
..TT~~~~.T....TT..TT.........................TT...
.T~~~~~~~T~..................TT.....TT.....T...T..
~~~~~~~~~~~~~~................~..........T......TT
~~~~~~~~~~~~~~~~~~~~....~~~~~~~~~~~.......TT......
~~~~...~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.............
~~~..T..~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~............
~~~.TTT.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.......TT.
~~~.TT..~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~........
~~~~TT~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.......
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~....
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~####~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#~~~~~~~~
~~~~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~###~~~~~~~~~~~~~~~~~~~~~~~~~~T~~~~
~~~~~~~~~~~~~~~~##~~~~~~~~~~~~~~~~~~~~~~~~~~T~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~..~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~.T.~~~~~~~~~~~#~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~.T~~~~~~~~~~~~#~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###~~~~~~
~~~~~~~~~~~~~~~~~~~~########~~~~~~~~~~~~~#~~~~~~~~
~~~~~~~~~~~~~~~~~~###~~~~~~###~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~##~~~~~~~~~~#~~~~~~~~~~~~~~~~~~~~
~~~T~~~~~~~~~~~~##~~~~~~~~~~~###~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~#~~~~~~~~~~~~~~#~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~##~~~~~~~~~~~~>~##~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~##~~~~~~~~~~~~~~##~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~#~~#########~~##~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~##*#~~~~~~~####~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]