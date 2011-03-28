-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

defineTile('!', "ROCK_VAULT", nil, nil, nil, {room_map={special=false, room=false, can_open=true}})
defineTile(' ', "GRASS")
defineTile('+', "DOOR")
defineTile('X', {"HARDTREE","HARDTREE2","HARDTREE3","HARDTREE4","HARDTREE5","HARDTREE6","HARDTREE7","HARDTREE8","HARDTREE9","HARDTREE10","HARDTREE11","HARDTREE12","HARDTREE13","HARDTREE14","HARDTREE15","HARDTREE16","HARDTREE17","HARDTREE18","HARDTREE19","HARDTREE20"})
defineTile('^', "GRASS", nil, nil, {random_filter={add_levels=5}})
defineTile('#', "GRASS", nil, {random_filter={name="honey tree"}})
defineTile('q', "GRASS", {random_filter={add_levels=10, tome_mod="vault"}}, {random_filter={name="brown bear", add_levels=10}})
defineTile('Q', "GRASS", {random_filter={add_levels=20, tome_mod="vault"}}, {random_filter={name="grizzly bear", add_levels=20}})

startx = 2
starty = 10

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

return {
[[XXXXXXXXXX]],
[[XXX   XXXX]],
[[XX #q# XXX]],
[[XX qQq XXX]],
[[XX #q# XXX]],
[[XXX   XXXX]],
[[XXXX XXXXX]],
[[XXXX   XXX]],
[[XXXXXX!XXX]],
[[XX^^^^ XXX]],
[[XX XXXXXXX]],
}
