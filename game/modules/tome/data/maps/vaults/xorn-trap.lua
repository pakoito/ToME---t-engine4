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

setStatusAll{no_teleport=true}

defineTile(' ', "FLOOR")
defineTile('#', "HARDWALL")
defineTile(':', "WALL")
defineTile('^', "FLOOR", {random_filter={add_levels=20, type='jewelry'}}, nil, {random_filter={add_levels=50, name='lethargy trap'}})
defineTile('X', "FLOOR", {random_filter={add_levels=15, tome_mod="gvault"}}, {random_filter={add_levels=15, subtype="xorn"}})

startx = 4
starty = 4

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

return {
[[#### ####]],
[[#XX# #XX#]],
[[#XX# #XX#]],
[[##:: ::##]],
[[    ^    ]],
[[###: :###]],
[[#XX: :XX#]],
[[#XX# #XX#]],
[[#### ####]],
}