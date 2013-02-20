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

defineTile('.', "FLOOR")
defineTile('D', "DOOR")
defineTile('!', "DOOR_VAULT")
defineTile('X', "HARDWALL")
defineTile('W', "FLOOR", {random_filter={subtype="staff", tome_mod="vault", add_levels=4}})
defineTile('S', "FLOOR", {random_filter={type="scroll", ego_chance=25, add_levels=4}})
defineTile('M', "FLOOR", nil, {random_filter={name="skeleton mage", add_levels=4}})

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

return {
[[.........]],
[[.XXXXXXX.]],
[[.XSSSSSX.]],
[[.XXXDXXX.]],
[[.X..M..X.]],
[[.X.M.M.X.]],
[[.X..M..X.]],
[[.XDX!XDX.]],
[[.XWX.XWX.]],
[[.XXX.XXX.]],
[[.........]],
}
