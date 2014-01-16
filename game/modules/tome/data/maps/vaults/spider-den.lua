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

setStatusAll{no_teleport=true, vault_only_door_open=true}
rotates = {"default", "90", "180", "270", "flipx", "flipy"}
startx = 7
starty = 0

defineTile('.', "FLOOR")
defineTile('X', "HARDWALL")
defineTile('#', "DOOR_VAULT", nil, nil, nil, {room_map={special=false, room=false, can_open=true}})

defineTile('s', "FLOOR", nil , {random_filter={add_levels=5,type="spiderkin",subtype="spider"}})
defineTile('S', "FLOOR", {random_filter={add_levels=10, tome_mod=vault}}, {random_filter={add_levels=10, type="spiderkin",subtype="spider"}})
defineTile('g', "FLOOR", {random_filter={add_levels=15, tome_mod=gvault}}, {random_filter={add_levels=15, type="spiderkin",subtype="spider"}})
defineTile('B', "FLOOR", {random_filter={add_levels=20, tome_mod=gvault}}, {random_filter={add_levels=20, type="spiderkin",subtype="spider"}})

defineTile('^', "FLOOR", nil, nil, {random_filter = {name="poison blast trap", add_levels=20}})

return {
[[...XXXX#XXXX...]],
[[..XXSs^.^ssXX..]],
[[.XXS^XXXXX^SXX.]],
[[XX.sS^s^s^Ss.XX]],
[[Xs.S.s.ggg..ssX]],
[[XS.s^S.gBgS^SSX]],
[[Xss..ssggg.ss.X]],
[[XXsSsS^s^.SsSXX]],
[[.XX^Ss.Ss.s.XX.]],
[[..XXsS.s^SsXX..]],
[[...XXXXXXXXX...]],
}