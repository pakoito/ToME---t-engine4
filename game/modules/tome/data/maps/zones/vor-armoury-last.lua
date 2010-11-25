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

startx = 0
starty = 34

defineTile(".", "FLOOR")
defineTile("~", "DEEP_WATER")
defineTile("#", "HARDWALL")
defineTile("$", "FLOOR", {random_filter={add_levels=5, ego_chance=30}})
defineTile("%", "LAVA_FLOOR")
defineTile("*", "LAVA_FLOOR", {random_filter={add_levels=20}}, {random_filter={name="greater multi-hued wyrm", add_levels=50}})
defineTile("=", "LAVA_FLOOR", {random_filter={unique=true, not_properties={"lore"}}}, {random_filter={name="greater multi-hued wyrm", add_levels=50}})
--defineTile("^", "LAVA_FLOOR", "ZEMEKKYS_HAT", {random_filter={name="greater multi-hued wyrm", add_levels=50}})
defineTile("^", "LAVA_FLOOR", nil, {random_filter={name="greater multi-hued wyrm", add_levels=50}})
defineTile("+", "DOOR")
defineTile('<', "UP")
defineTile("o", "FLOOR", nil, {random_filter={add_levels=5, subtype="orc"}})
defineTile("G", "FLOOR", nil, "GNARG")
defineTile("|", "FLOOR", "ATHAME")

return [[
.....~~############################
.....~##.#^%%%%%%%%=#.............#
....~~#..#%%%%%%%%%%#.............#
....~##..#%%%%%%%%%%#.$$$$...$$$$.#
....~#...#%%%%%%%%%%#.$##$...$##$.#
...~~#...+%%%%**%%%%#.$##$...$##$.#
..~~##...+%%%%**%%%%#.$$$$...$$$$.#
..~##....#%%%%%%%%%%#%.o.o###o.o..#
..~#.....#%%%%%%%%%%#%%...###...%%#
.~~#.....#%%%%%%%%%%#%%...$$$..%%$#
~~~#.....#%%%%%%%%%=#%%%%%%%%%%%%$#
~#####+##############%..........%$#
~#..o.o.o.........o##...oooooo...$#
~#................o##............$#
~#.................+............G|#
~#.................+.............$#
~#................o##...oooooo...$#
~#..o.o.o.........o##%..........%$#
~#####+####+#####+###%%%%%%%%%%%%$#
~~~#....#.....#....##%%...$$$..%%$#
..~#....#.....#....##%%...###...%%#
..~#....#....##....##%....###.....#
..~##...#....#.....##..o.o....o.o.#
..~~##..#....#.....##.$$$$...$$$$.#
...~~#..#....#.....##.$##$...$##$.#
....~##.##...#.....##.$##$...$##$.#
....~~#..#...#.....##.$$$$...$$$$.#
.....~####+######+###.............#
.....~~#...#...#...##.............#
......~#...#...#...##.............#
......~#...#...#...################
......~#...+...+...+..........#####
......~#...#...#...#..........#$$$#
......~+...#...#...#...........#$$#
<.....~############################]]
