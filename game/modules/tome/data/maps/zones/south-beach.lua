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

startx = 16
starty = 0
endx = 16
endy = 0


-- defineTile section
defineTile("~", "DEEP_OCEAN_WATER")
defineTile(",", "SAND")
defineTile("_", "GRASS_ROAD_STONE")
defineTile("=", "UMBRELLA")
defineTile("!", "BASKET")
defineTile(".", "GRASS")
defineTile("t", "TREE")
defineTile("<", "BEACH_UP")

-- addSpot section
addSpot({0, 17}, "spawn", "yaech")
addSpot({1, 17}, "spawn", "yaech")
addSpot({2, 17}, "spawn", "yaech")
addSpot({3, 17}, "spawn", "yaech")
addSpot({4, 17}, "spawn", "yaech")
addSpot({5, 17}, "spawn", "yaech")
addSpot({6, 17}, "spawn", "yaech")
addSpot({7, 17}, "spawn", "yaech")
addSpot({8, 17}, "spawn", "yaech")
addSpot({9, 17}, "spawn", "yaech")
addSpot({10, 17}, "spawn", "yaech")
addSpot({11, 17}, "spawn", "yaech")
addSpot({12, 17}, "spawn", "yaech")
addSpot({13, 17}, "spawn", "yaech")
addSpot({14, 17}, "spawn", "yaech")
addSpot({15, 17}, "spawn", "yaech")
addSpot({0, 18}, "spawn", "yaech")
addSpot({1, 18}, "spawn", "yaech")
addSpot({2, 18}, "spawn", "yaech")
addSpot({3, 18}, "spawn", "yaech")
addSpot({4, 18}, "spawn", "yaech")
addSpot({5, 18}, "spawn", "yaech")
addSpot({6, 18}, "spawn", "yaech")
addSpot({7, 18}, "spawn", "yaech")
addSpot({8, 18}, "spawn", "yaech")
addSpot({9, 18}, "spawn", "yaech")
addSpot({10, 18}, "spawn", "yaech")
addSpot({11, 18}, "spawn", "yaech")
addSpot({12, 18}, "spawn", "yaech")
addSpot({13, 18}, "spawn", "yaech")
addSpot({14, 18}, "spawn", "yaech")
addSpot({15, 18}, "spawn", "yaech")
addSpot({0, 19}, "spawn", "yaech")
addSpot({1, 19}, "spawn", "yaech")
addSpot({2, 19}, "spawn", "yaech")
addSpot({3, 19}, "spawn", "yaech")
addSpot({4, 19}, "spawn", "yaech")
addSpot({5, 19}, "spawn", "yaech")
addSpot({6, 19}, "spawn", "yaech")
addSpot({7, 19}, "spawn", "yaech")
addSpot({8, 19}, "spawn", "yaech")
addSpot({9, 19}, "spawn", "yaech")
addSpot({10, 19}, "spawn", "yaech")
addSpot({11, 19}, "spawn", "yaech")
addSpot({12, 19}, "spawn", "yaech")
addSpot({13, 19}, "spawn", "yaech")
addSpot({14, 19}, "spawn", "yaech")
addSpot({15, 19}, "spawn", "yaech")

-- addZone section

-- ASCII map section
return [[
,..t.t.tt..tt...<t..
,,...t......tt.__tt.
,,..tt..t....t__tttt
,,,.....t..____....t
,,,,....tt._..t.t...
,,,,,....t__ttt..t..
,,,,,....__tt..t..t.
,,,,,,..._....tt..t.
~,,,,,,.._....t.....
~,,,,,,,._..........
~~,,,,,,,,,........,
~~~,,,=,,,,,,,,,,,,,
~~~~,,!,,,,,,,,,,,,,
~~~~~,,,,,,,,,,,,,,,
~~~~~~,,,,,,,,,,,,,,
~~~~~~~~~~,,,~,,~~~~
~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~]]