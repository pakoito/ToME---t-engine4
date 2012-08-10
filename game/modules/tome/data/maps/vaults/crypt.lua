-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

defineTile(' ', "FLOOR")
defineTile('!', "DOOR_VAULT", nil, nil, nil, {room_map={special=false, room=false, can_open=true}})
defineTile('+', "DOOR")
defineTile('X', "HARDWALL")
defineTile('^', "FLOOR", {random_filter={add_levels=5,tome_mod="vault"}}, {random_filter={type="undead"}})
defineTile('u', "FLOOR", {random_filter={}}, {random_filter={type="undead", subtype="vampire", name="lesser vampire"}})
defineTile('v', "FLOOR", {random_filter={add_levels=5,tome_mod="vault"}}, {random_filter={add_levels=5, type="undead", subtype="vampire", name="vampire"}})
defineTile('U', "FLOOR", {random_filter={add_levels=10, tome_mod="gvault"}}, {random_filter={add_levels=10, type="undead", subtype="vampire", name="master vampire"}})
defineTile('V', "FLOOR", {random_filter={add_levels=15, tome_mod="gvault"}}, {random_filter={add_levels=15, type="undead", subtype="vampire", name="elder vampire"}})
defineTile('L', "FLOOR", {random_filter={add_levels=20, tome_mod="gvault"}}, {random_filter={add_levels=20, type="undead", subtype="vampire", name="vampire lord"}})
defineTile('W', "FLOOR", {random_filter={add_levels=15, tome_mod="gvault"}}, {random_filter={add_levels=15, type="undead", subtype="wight", name="grave wight"}})

startx = 0
starty = 6

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

return {
[[XXXXXXXXXXXXXXXXXXXXXXXXXXXXX]],
[[XX^^^X^^^X^^^X^^^XXXXXXXXXXXX]],
[[XX^u^X^v^X^U^X^V^XXXX^WXXXXXX]],
[[XX^ ^X^ ^X^ ^X^ ^XXXX^  WXXXX]],
[[XXX XXX XXX XXX XXXXX^ XXXXXX]],
[[XXX+XXX+XXX+XXX+XXXXX^  LXXXX]],
[[!                  +   XXXXXX]],
[[XXXXX+XXX+XXX+XXX+XXX^  LXXXX]],
[[XXXXX XXX XXX XXX XXX^ XXXXXX]],
[[XXXX^ ^X^ ^X^ ^X^ ^XX^  WXXXX]],
[[XXXX^u^X^v^X^U^X^V^XX^WXXXXXX]],
[[XXXX^^^X^^^X^^^X^^^XXXXXXXXXX]],
[[XXXXXXXXXXXXXXXXXXXXXXXXXXXXX]],
}