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

setStatusAll{no_teleport=true}

defineTile('!', "ROCK_VAULT_DARK", nil, nil, nil, {room_map={special=false, room=false, can_open=true}})
defineTile(' ', "GRASS_DARK1")
defineTile('+', "DOOR")
defineTile('X', {"HARDTREE_DARK1","HARDTREE_DARK2","HARDTREE_DARK3","HARDTREE_DARK4","HARDTREE_DARK5","HARDTREE_DARK6","HARDTREE_DARK7","HARDTREE_DARK8","HARDTREE_DARK9","HARDTREE_DARK10","HARDTREE_DARK11","HARDTREE_DARK12","HARDTREE_DARK13","HARDTREE_DARK14","HARDTREE_DARK15","HARDTREE_DARK16","HARDTREE_DARK17","HARDTREE_DARK18","HARDTREE_DARK19","HARDTREE_DARK20"})
defineTile('^', "GRASS_DARK1", nil, nil, {random_filter={add_levels=5}})
defineTile('#', "GRASS_DARK1", nil, {random_filter={name="honey tree"}})
defineTile('q', "GRASS_DARK1", {random_filter={add_levels=10, ego_chance=25}}, {random_filter={name="brown bear", add_levels=10}})
defineTile('Q', "GRASS_DARK1", {random_filter={add_levels=20, ego_chance=25}}, {random_filter={name="grizzly bear", add_levels=20}})

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
