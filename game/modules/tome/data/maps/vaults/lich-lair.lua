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

--32 chambers
-- lich liar
setStatusAll{no_teleport=true}

startx = 9
starty = 16

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

defineTile('.', "FLOOR")
defineTile('X', "HARDWALL")
defineTile('!', "DOOR_VAULT", nil, nil, nil, {room_map={special=false, room=false, can_open=true}})

defineTile('a', "FLOOR", nil, {random_filter={name="armoured skeleton warrior", add_levels=10}})
defineTile('m', "FLOOR", nil, {random_filter={name="skeleton mage", add_levels=10}})
defineTile('g', "FLOOR", nil, {random_filter={subtype="ghoul", add_levels=10}})
defineTile('l', "FLOOR", nil, {random_filter={type = "undead", subtype = "lich",}})
defineTile('$', "FLOOR", {random_filter={add_levels=20, tome_mod="gvault"}})

return {
[[XXXXXXXXXXXXXXXXX]],
[[Xm.ggg..g..ggg.mX]],
[[X.X...........X.X]],
[[X..a.........a..X]],
[[X...XXX.a.XXX...X]],
[[X...X.......X...X]],
[[X...X.a.l.a.X...X]],
[[Xm.aX.......Xa.mX]],
[[X...Xg..a..gX...X]],
[[X...Xg$$$$$gX...X]],
[[X...Xg$$$$$gX...X]],
[[X...XXXXXXXXX...X]],
[[Xm.a.a.a.a.a.a.mX]],
[[X.X...........X.X]],
[[Xm.............mX]],
[[XXXXXXXX!XXXXXXXX]],
}