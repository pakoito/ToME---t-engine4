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

startx = 5
starty = 14
endx = 12
endy = 12

-- defineTile section
defineTile("U", "FLOOR", nil, {random_filter={type="demon"}})
defineTile('"', "OLD_FLOOR", nil, {random_filter={name="greater multi-hued wyrm",add_levels=12}})
defineTile("#", "OLD_WALL")
defineTile("E", "GRASS", nil, {random_filter={type="elemental"}})
defineTile("$", "FLOOR", nil, {random_filter={type="undead", subtype="giant"}})
defineTile("X", "HARDWALL")
defineTile("~", "FLOOR")
defineTile('*', "GENERIC_LEVER_DOOR", nil, nil, nil, {lever_action=4, lever_action_value=0, lever_action_kind="doors"}, {type="lever", subtype="door"})
defineTile('&', "GENERIC_LEVER", nil, nil, nil, {lever=1, lever_kind="doors", lever_radius=50})
defineTile("+", "DOOR")
defineTile("<", "TUP")
defineTile(",", "GRASS")
defineTile(".", "FLOOR")
defineTile(" ", "OLD_FLOOR")
defineTile("!", "WALL")
defineTile("T", "TREE")

-- ASCII map section
return [[
XXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXX.+.+.XXXXXXXXXX
XXXXXXX....X+X....XXXXXXX
XXXXX...X+XX.XXXX...XXXXX
XXXX..XX# #X.X!~X+X..XXXX
XXX..XXX# #X.XU!~!XX..XXX
XXX.XX### #X.X!~!U!XX.XXX
XX..X##   #X.X~!U!~!X..XX
XX.XX#    #X.X!~!~!UXX.XX
XX.XX# &" #X.XU!~!U!~X.XX
X..XX######X.X&U!~!~!X..X
X+XXXXXXXXXX*XXXXXXXXXX+X
X.+........*<*........+.X
X+XXXXXXXXXX*XXX+XXXXXX+X
X..XX.....&X.XX,,,XXXX..X
XX.XX......X.XEE,EEXXX.XX
XX.XX......X.XEETEEXXX.XX
XX..X....$$X.XEE,EEXX..XX
XXX.XXXXXX+X.XX,,,XXX.XXX
XXX..XX.$..X.XXX&XXX..XXX
XXXX..X+XXXX.XXXXXX..XXXX
XXXXX...XXXX.XXXX...XXXXX
XXXXXXX....X+X....XXXXXXX
XXXXXXXXXX.+.+.XXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXX]]
