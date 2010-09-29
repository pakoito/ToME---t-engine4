-- ToME - Tales of Middle-Earth
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

defineTile('.', "FLOOR")
defineTile('#', "WALL")
defineTile('X', "HARDWALL")
defineTile('8', "FLOOR", {random_filter={add_levels=15, ego_chance=25}}, {random_filter={add_levels=20}})

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

return {
[[.......................................]],
[[.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.]],
[[.#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8X.]],
[[.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX#X.]],
[[.X8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8X.X.]],
[[.X#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX#X#X.]],
[[.X8X8#8#8#8#8#8#8#8#8#8#8#8#8#8#8X8X.X.]],
[[.X#X#XXXXXXXXXXXXXXXXXXXXXXXXXXX#X#X#X.]],
[[.X8X8X8#8#8#8#8#8#8#8#8#8#8#8#8#8X8X.X.]],
[[.X#X#X#XXXXXXXXXXXXXXXXXXXXXXXXXXX#X#X.]],
[[.X8X8X8#8#8#8#8#8#8#8#8#8#8#8#8#8#8X.X.]],
[[.X#X#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX#X.]],
[[.X8X8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#.X.]],
[[.X#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.]],
[[.X8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#.]],
[[.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.]],
[[.......................................]],
}