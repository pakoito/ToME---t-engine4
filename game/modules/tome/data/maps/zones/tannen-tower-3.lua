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

startx = 12
starty = 12
endx = 19
endy = 4

-- defineTile section
defineTile("X", "HARDWALL")
defineTile("~", "DEEP_WATER")
defineTile("<", "TUP")
defineTile(">", "TDOWN")
defineTile(".", "FLOOR")

-- addSpot section

-- ASCII map section
return [[
XXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXX~~~~~XXXXXXXXXX
XXXXXXX~~~.XXX~~~~XXXXXXX
XXXXX~~~XXXXXXXXX~~~XXXXX
XXXX~~XXXXXXXXXXXXX<~XXXX
XXX~~XXXXXXXXXXXXXXX~~XXX
XXX~XX~~~~~~~~~~~~~XX~XXX
XX~~XX~XXXXXXXXXXX~XX~~XX
XX~XXX~X~~.~~~~~~X.XXX~XX
XX~XXX~X~XXXXXXX~X~XXX~XX
X~~XXX~X~X~~~~~X~X~XXX~~X
X~XXXX~X~X~XXX~X~X~XXXX~X
X~XXXX~X~X~~>X~X~X~XXXX~X
X~XXXX~X~XXXXX~X~X~XXXX~X
X~~XXX.X~~~~~~~X~X~XXX~~X
XX~XXX~XXXXXXXXX~X~XXX~XX
XX.XXX~~~~~~~~~~~X~XXX~XX
XX~~XXXXXXXXXXXXXX~XX~.XX
XXX~~~~~~~~~~~.~~~~XX~XXX
XXX~~XXXXXXXXXXXXXXX~~XXX
XXXX~~XXXXXXXXXXXXX~~XXXX
XXXXX~~~XXXXXXXXX~~~XXXXX
XXXXXXX~~~.XXX~~~~XXXXXXX
XXXXXXXXXX~~~~~XXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXX]]
