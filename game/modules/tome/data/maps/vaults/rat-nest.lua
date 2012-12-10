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

setStatusAll{no_teleport=true, no_vaulted=true}

defineTile('.', "FLOOR")
defineTile('D', "DOOR")
defineTile('X', "HARDWALL")
defineTile('M', "FLOOR", nil, {random_filter={subtype="molds", add_levels=4}})
defineTile('W', "FLOOR", nil, {random_filter={name="giant white rat"}})
defineTile('B', "FLOOR", {random_filter={type="money"}}, {random_filter={name="giant brown rat"}})
defineTile('G', "FLOOR", {random_filter={add_levels=4}}, {random_filter={name="giant grey rat"}})
rotates = {"default", "90", "180", "270", "flipx", "flipy"}

return {
[[.........WW......WW....]],
[[.XXXXXXXXX..XX..XX....W]],
[[.XMWWGWBGWX.XB..WW...X.]],
[[.DBWBXXWWBDWD..WXXB..D.]],
[[.XGBWBWWBMXWXM..MBG.MX.]],
[[.XXXXXXXXXXWXXXXXXXXX.W]],
[[...WW..............WW.W]],
}
