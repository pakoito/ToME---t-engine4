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

-- Rain of Death
setStatusAll{no_teleport=true}

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

defineTile('.', "FLOOR")
defineTile('X', "HARDWALL")
defineTile('v', "LAVA")
defineTile('!', "DOOR_VAULT", nil, nil, nil, {room_map={special=false, room=false, can_open=true}})

-- All a are Skeleton Master Archer
defineTile('a', "FLOOR", nil, {random_filter={name="skeleton master archer"}})

defineTile('$', "FLOOR", {random_filter={add_levels=20, tome_mod="gvault"}})
defineTile('*', "FLOOR", {random_filter={add_levels=20, tome_mod="uvault"}})

return {
[[XXXXXXX!!XXXXXXX]],
[[X..v.av..v.av.$X]],
[[X..vvvv..vvvv..X]],
[[Xvv..........vvX]],
[[X.v..........v.X]],
[[Xav..........vaX]],
[[Xvv..........vvX]],
[[!......$X......!]],
[[!......X*......!]],
[[Xvv..........vvX]],
[[X.v..........vaX]],
[[Xav..........v.X]],
[[Xvv..........vvX]],
[[X..vvvv..vvvv..X]],
[[X$.va.v..va.v..X]],
[[XXXXXXX!!XXXXXXX]],
}
