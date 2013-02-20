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
rotates = {"default", "90", "180", "270", "flipx", "flipy"}
startx = 7
starty = 0

--Traps
defineTile('f',"FLOOR", nil, nil, {random_filter={name="ice blast trap"}})

--Greed will be your undoing
defineTile('S',"FLOOR", {random_filter={add_levels = 10, tome_mod = "vault"}}, nil, {add_levels=20, random_filter={name="ice blast trap"}})

--Enemies
defineTile('o',"FLOOR", nil, {random_filter={name = "black ooze"}}) -- to lull them into a false sense of security
defineTile('w',"FLOOR", nil, {random_filter={add_levels=10,name = "wretchling"}})
defineTile('D',"FLOOR", nil, {random_filter={add_levels=20,name = "venom wyrm"}})
defineTile('H',"FLOOR", nil, {random_filter={add_levels=10,name = "worm that walks"}})

--Goodies
defineTile('j',"FLOOR",{random_filter={add_levels=10, tome_mod = "vault"}})
defineTile('$',"FLOOR",{random_filter={add_levels = 10, tome_mod = "gvault"}})
defineTile('%',"FLOOR",{random_filter={add_levels = 20, tome_mod = "gvault"}})
defineTile('&',"FLOOR",{random_filter={add_levels = 20, tome_mod = "vault"}})

--Tiles
defineTile('.', "FLOOR")
defineTile('X', "HARDWALL")
defineTile('#', "DOOR_VAULT", nil, nil, nil, {room_map={special=false, room=false, can_open=true}})
defineTile('=', "DOOR")

return {
[[XXXXXXX#XXXXXXX]],
[[X$&$$$X.X$$$&$X]],
[[XXXXX=X.X=XXXXX]],
[[X...XfX.XfX...X]],
[[X.w...XoX...w.X]],
[[X.X.X.X.X.X.X.X]],
[[X..X.XX.XX.X..X]],
[[XX..X.X=X.X..XX]],
[[Xw.X.X...X.X.wX]],
[[XX.....S.....XX]],
[[X.X.XX.X.XX.X.X]],
[[X...X.X.X.X...X]],
[[X..X.X.X.X.X..X]],
[[X..DX.XHX.XD..X]],
[[XXXXXX.X.XXXXXX]],
[[X%jjj=fXf=jjj%X]],
[[XXXXXXXXXXXXXXX]],
}
