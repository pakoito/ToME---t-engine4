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

startx = 19
starty = 4
endx = 12
endy = 12

-- defineTile section
defineTile("X", "HARDWALL")
defineTile("+", "DOOR")
defineTile("<", "TUP")
defineTile(">", "TDOWN")
defineTile(".", "FLOOR")

-- addSpot section

-- ASCII map section
return [[
XXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXX.....XXXXXXXXXX
XXXXXXX....XXX....XXXXXXX
XXXXX...XXXXXXXXX...XXXXX
XXXX..XXX...X...XXX>.XXXX
XXX..XX.....X.....XX..XXX
XXX.XX......+......XX.XXX
XX..X.......X.......X..XX
XX.XX.......X.......XX.XX
XX.X......XXXX.......X.XX
X..X......+..XX......X..X
X.XX.....XX...XX.....XX.X
X.XXXXXXXX..<..XXX+XXXX.X
X.XX.....XX...XX.....XX.X
X..X......XX.XX......X..X
XX.X.......XXX.......X.XX
XX.XX.......X.......XX.XX
XX..+.......X.......X..XX
XXX.XX......+......XX.XXX
XXX..XX.....X.....XX..XXX
XXXX..XXX...X...XXX..XXXX
XXXXX...XXXXXXXXX...XXXXX
XXXXXXX....XXX....XXXXXXX
XXXXXXXXXX.....XXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXX]]
