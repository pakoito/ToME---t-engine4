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

setStatusAll{no_teleport=true}

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

startx = 13
starty = 12

defineTile('.', "FLOOR")
defineTile('X', "HARDWALL")
defineTile('#', "WALL")
defineTile('!', "DOOR_VAULT")
defineTile('~', "DEEP_WATER")

defineTile('n', "FLOOR", nil, {random_filter={subtype="naga", add_levels=10}})
defineTile('1', "FLOOR", nil, {random_filter={no_breath=1, add_levels=5}})

defineTile('$', "FLOOR", {random_filter={add_levels=10, tome_mod="gvault"}})

return {
[[#XXXXX###############XXXXX#]],
[[XX~~~XX###XXXXXXX###XX~~~XX]],
[[X~111~XXXXX~~~~~XXXXX~111~X]],
[[X~1n1~~~~~~~~~~~~~~~~~1n1~X]],
[[X~111~XXXXXXX~XXXXXXX~111~X]],
[[XX~~~XXXXXXXX~XXXXXXXX~~~XX]],
[[#XX~XXXXXXXXX~XXXXXXXXX~XX#]],
[[##X~XXX$$$XX~~~XX$$$XXX~X##]],
[[##X~XXX111X~...~X111XXX~X##]],
[[##X~~~~1n1X~...~X1n1~~~~X##]],
[[##XXXXX111X~...~X111XXXXX##]],
[[######X$$$XX~~~XX$$$X######]],
[[######XXXXXXX!XXXXXXX######]],
}
