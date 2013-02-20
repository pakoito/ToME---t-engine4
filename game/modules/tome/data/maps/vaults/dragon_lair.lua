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

setStatusAll{no_teleport=true, vault_only_door_open=true}

startx = 25
starty = 6

defineTile('!', "ROCK_VAULT", nil, nil, nil, {room_map={special=false, room=false, can_open=true}})
defineTile(' ', "SAND")
defineTile('X', "HARDMOUNTAIN_WALL")
defineTile('$', "SAND", {random_filter={add_levels=15, tome_mod="gvault"}})
defineTile('D', "SAND", {random_filter={add_levels=20, tome_mod="uvault"}}, {random_filter={name="greater multi-hued wyrm", add_levels=50}})
defineTile('d', "SAND", nil, {random_filter={name="multi-hued drake hatchling", add_levels=20}})

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

return {
[[  XXXXXXX X X XXX    X    ]],
[[ XXXd  XXXXXXXXdXX XXXXXX ]],
[[XXXXXXX     XXXX XXX   XXX]],
[[XdXXX   $$$   Xd XXX X  XX]],
[[XX     $$$$$  dXXX   XX XX]],
[[Xd    $$$D$$$      XXXX!XX]],
[[XX     $$$$$   XXXXXXXX   ]],
[[XXXXX   $$$   XXXXXXXXXXXX]],
[[  XXX X     XXX XXXXXXXXX ]],
[[ XXXX XXXXXX ddXXXXXX     ]],
[[ XXXdXX  XXXXXXXXXXXXX    ]],
[[  XXXX     XXXXXXXX       ]],
}