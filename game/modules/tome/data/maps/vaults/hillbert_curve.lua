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

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

startx = 15
starty = 16

defineTile(' ', "FLOOR")
defineTile('!', "DOOR_VAULT")
defineTile('+', "DOOR")
defineTile('#', "HARDWALL")
defineTile('c', "FLOOR", {random_filter={add_levels=10, ego_chance=25}})
defineTile('$', "FLOOR", {random_filter={add_levels=25, ego_chance=25}})
defineTile('~', "FLOOR", {random_filter={add_levels=10, ego_chance=25}}, nil, {random_filter={add_levels=10}})
defineTile('^', "FLOOR", nil, nil, {random_filter={add_levels=5}})

defineTile('s', "FLOOR", nil, {random_filter={add_levels=5, name="master skeleton archer"}})
defineTile('o', "FLOOR", {random_filter={add_levels=5}}, {random_filter={add_levels=5}})
defineTile('O', "FLOOR", {random_filter={add_levels=10, ego_chance=25}}, {random_filter={add_levels=10}})
defineTile('P', "FLOOR", {random_filter={add_levels=15, ego_chance=25}}, {random_filter={add_levels=15}})

return {
[[#################]],
[[#^^^#   #   #  s#]],
[[#P# # # #o#~#~# #]],
[[# # ss# #o#~s~# #]],
[[# #####s#o#####^#]],
[[#  O#  O#o  #cO #]],
[[###s# ##### #O###]],
[[#c  #s^^+   #s  #]],
[[#c############# #]],
[[#c# ooo # ooP #s#]],
[[#~# ### # ### #^#]],
[[#c  #s  #   # ~ #]],
[[#####s#####s#####]],
[[# PP#  O#  o# c #]],
[[# # ### #~###o# #]],
[[#$#s    #    o# #]],
[[###############!#]],
}
