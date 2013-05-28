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

defineTile('<', "GRASS_UP_WILDERNESS")
defineTile('t', "TREE")
defineTile('~', "DEEP_OCEAN_WATER")
defineTile('.', "GRASS")
defineTile('-', "FIELDS")
defineTile('_', "GRASS_ROAD_STONE")
defineTile(',', "SAND")
defineTile('!', "ROCK")
defineTile('#', "HARDWALL")
defineTile('+', "DOOR")
defineTile('=', "LAVA")
defineTile("?", "OLD_FLOOR")
defineTile(":", "FLOOR")
defineTile("&", "POST")
defineTile("@", "FLOOR", nil, "PROTECTOR_MYSSIL")
defineTile("'", "DOOR")
defineTile("*", "CLOSED_GATE")
defineTile("^", "OPEN_GATE")

defineTile('1', "HARDWALL", nil, nil, "TRAINER")
defineTile('2', "HARDWALL", nil, nil, "SWORD_WEAPON_STORE")
defineTile('3', "HARDWALL", nil, nil, "AXE_WEAPON_STORE")
defineTile('5', "HARDWALL", nil, nil, "MACE_WEAPON_STORE")
defineTile('6', "HARDWALL", nil, nil, "KNIFE_WEAPON_STORE")
defineTile('7', "HARDWALL", nil, nil, "LIGHT_ARMOR_STORE")
defineTile('8', "HARDWALL", nil, nil, "HEAVY_ARMOR_STORE")
defineTile('4', "HARDWALL", nil, nil, "HERBALIST")
defineTile('9', "HARDWALL", nil, nil, "LIBRARY")
defineTile('A', "HARDWALL", nil, nil, "ARCHER_WEAPON_STORE")
defineTile('B', "HARDWALL", nil, nil, "MINDSTAR_WEAPON_STORE")

startx = 24
starty = 49
endx = 24
endy = 49

-- addSpot section
addSpot({32, 7}, "portal", "portal")
addSpot({39, 8}, "portal", "portal")
addSpot({38, 15}, "portal", "portal")
addSpot({32, 15}, "portal", "portal")
addSpot({35, 11}, "quest", "arena")
addSpot({28, 12}, "quest", "outside-arena")
addSpot({15, 31}, "arrival", "rhaloren")
addSpot({16, 31}, "arrival", "rhaloren")
addSpot({17, 31}, "arrival", "rhaloren")
addSpot({18, 31}, "arrival", "rhaloren")
addSpot({19, 31}, "arrival", "rhaloren")
addSpot({20, 31}, "arrival", "rhaloren")
addSpot({15, 32}, "arrival", "rhaloren")
addSpot({16, 32}, "arrival", "rhaloren")
addSpot({17, 32}, "arrival", "rhaloren")
addSpot({18, 32}, "arrival", "rhaloren")
addSpot({19, 32}, "arrival", "rhaloren")
addSpot({20, 32}, "arrival", "rhaloren")
addSpot({15, 33}, "arrival", "rhaloren")
addSpot({16, 33}, "arrival", "rhaloren")
addSpot({17, 33}, "arrival", "rhaloren")
addSpot({18, 33}, "arrival", "rhaloren")
addSpot({19, 33}, "arrival", "rhaloren")
addSpot({20, 33}, "arrival", "rhaloren")
addSpot({15, 34}, "arrival", "rhaloren")
addSpot({16, 34}, "arrival", "rhaloren")
addSpot({17, 34}, "arrival", "rhaloren")
addSpot({18, 34}, "arrival", "rhaloren")
addSpot({19, 34}, "arrival", "rhaloren")
addSpot({20, 34}, "arrival", "rhaloren")
addSpot({15, 35}, "arrival", "rhaloren")
addSpot({16, 35}, "arrival", "rhaloren")
addSpot({17, 35}, "arrival", "rhaloren")
addSpot({18, 35}, "arrival", "rhaloren")
addSpot({19, 35}, "arrival", "rhaloren")
addSpot({20, 35}, "arrival", "rhaloren")
addSpot({28, 16}, "arrival", "ziguranth")
addSpot({29, 16}, "arrival", "ziguranth")
addSpot({28, 17}, "arrival", "ziguranth")
addSpot({29, 17}, "arrival", "ziguranth")
addSpot({24, 7}, "arrival", "ziguranth")
addSpot({25, 7}, "arrival", "ziguranth")
addSpot({24, 8}, "arrival", "ziguranth")
addSpot({25, 8}, "arrival", "ziguranth")
addSpot({9, 13}, "arrival", "ziguranth")
addSpot({10, 13}, "arrival", "ziguranth")
addSpot({9, 14}, "arrival", "ziguranth")
addSpot({10, 14}, "arrival", "ziguranth")
addSpot({10, 30}, "arrival", "ziguranth")
addSpot({11, 30}, "arrival", "ziguranth")
addSpot({10, 31}, "arrival", "ziguranth")
addSpot({11, 31}, "arrival", "ziguranth")
addSpot({18, 21}, "arrival", "ziguranth")
addSpot({19, 21}, "arrival", "ziguranth")
addSpot({18, 22}, "arrival", "ziguranth")
addSpot({19, 22}, "arrival", "ziguranth")
addSpot({29, 35}, "arrival", "ziguranth")
addSpot({30, 35}, "arrival", "ziguranth")
addSpot({29, 36}, "arrival", "ziguranth")
addSpot({30, 36}, "arrival", "ziguranth")
addSpot({31, 23}, "arrival", "ziguranth")
addSpot({32, 23}, "arrival", "ziguranth")
addSpot({31, 24}, "arrival", "ziguranth")
addSpot({32, 24}, "arrival", "ziguranth")
addSpot({29, 12}, "quest", "sealed-gate")

-- addZone section

-- ASCII map section
return [[
~~~~~~~~~~~~~~~~~~~~~~~~~ttttttttttttttttttttttttt
~~~~~~~~~~~~~~~~~~~~~~~~~ttttttttttt..tttttttttttt
~~~~~~~~~~~~~..........~~tt###............tttttttt
~~~~~~~~~~~..............tt###.............ttttttt
~~~~~~~~~~.....#########...###..............tttttt
~~~~~~~~.......#:::@:::#...###..========.....ttttt
~~~~~~~~.......#:::::::#...#1#.==??????==....##ttt
~~~~~~~tt......#:##'##:#......==????????==...##ttt
~~~~~~ttt......#:#._.#:#......=??!!??????=...###tt
~~~~~tttt......###._.###.....==??????????==..###tt
~~~~~ttt..........._.........=????????????=..###tt
~~~~tttt........._____.......=????????????==.4#ttt
~~~tttt.........._ttt_....___=??????????!??=...ttt
~~~ttttt........._ttt_..___..=?????????!???=...ttt
~~...ttt.........________....==???!???????==...ttt
~~..............._ttt_........=???????????=.....tt
~~~.......#####.._ttt_........===???????===.....tt
~~~~~.....#####.._____..........=========.......tt
~~~~~.....#2#3#.................................tt
~~~.........................#######...##.......ttt
~~~.........................#######...B#.......ttt
~~~~........................#8#7#9#...........tttt
~~~~,,,.....................................tttttt
~~~~,,,,..................................tttttttt
~~~~~~,,,,..............t................ttttttttt
~~~~~~~~,,,............ttt..######..tt..tttttttttt
~~~~~~~~~,,...........ttttt.######...t.ttttttttttt
~~~~~~~~~,,,..........ttttt.5#6#A#.....ttttttttttt
~~~~~~~~~,,,,...........tt..............tttttttttt
~~~~~~~~~~,,,...........................tttttttttt
~~~~~~~~~~,,,,..........................tttttttttt
~~~~~~~~~~,,,,..........................tttttttttt
~~~~~~~~~~,,,,,..........................ttttttttt
~~~~~~~~~~~,,,,,...........................ttttttt
~~~~~~~~~~~,,,,,,,...........................ttttt
~~~~~~~~~~~~,,,,,,,...........................tttt
~~~~~~~~~~~~~,,,,,,,,,....................-----ttt
~~~~~~~~~~~~~~~,,,,,,,,,,,,,,,,,..&.......------tt
~~~~~~~~~~~~~~~~~~,,,,,,,,,,,,,,,.........------.t
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,,........------.t
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~,........------.t
~~~~~~~~~~~~~~~~~~~~~~~,,,,~~~~~~,t.......------.t
~~~~~~~~~~~~~~~~~~~~~~,,tt,,~~~~~,tt......------tt
~~~~~~~~~~~~~~~~~~~~~~,tttt,,,,,,,ttt.....------tt
~~~~~~~~~~~~~~~~~~~~~~,tttttt,,,tttttttt..------tt
~~~~~~~~~~~~~~~~~~~~~~,,tttttttttttttttttt-----ttt
~~~~~~~~~~~~~~~~~~~~~~~,,tttttttttttttttttttt..ttt
~~~~~~~~~~~~~~~~~~~~~~~,,ttttttttttttttttttttttttt
~~~~~~~~~~~~~~~~~~~~~~~,,ttttttttttttttttttttttttt
~~~~~~~~~~~~~~~~~~~~~~~,<ttttttttttttttttttttttttt]]
