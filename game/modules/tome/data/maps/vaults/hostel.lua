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

setStatusAll{no_teleport=true}

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

defineTile(' ', "FLOOR")
defineTile('+', "DOOR")
defineTile('!', "DOOR_VAULT")
defineTile('X', "HARDWALL")
defineTile('$', "FLOOR", {random_filter={add_levels=10, tome_mod="vault"}})
defineTile('~', "FLOOR", {random_filter={add_levels=5}}, nil, {random_filter={add_levels=5}})
defineTile('^', "FLOOR", nil, nil, {random_filter={add_levels=5}})
defineTile('o', "FLOOR", {random_filter={add_levels=10, tome_mod="vault"}}, {random_filter={add_levels=10}})
defineTile('O', "FLOOR", {random_filter={add_levels=15, tome_mod="vault"}}, {random_filter={add_levels=15}})
defineTile('P', "FLOOR", {random_filter={add_levels=20, tome_mod="gvault"}}, {random_filter={add_levels=20}})

startx = 28
starty = 8

return {
[[XXXXXXXXXXXXXXXXXXXXXXXXXXXXX]],
[[X~~^+                   ^+$$X]],
[[X~~^X XXXXXX+XXX+XXXXXX+XXXXX]],
[[XXXXX X ooXo  X   XPPX   $o X]],
[[X$$$X + ooX o X o XOOXo$oo  X]],
[[X   X X ooX XXX~~$X$$XXXX   X]],
[[XO ^X X ooXo OX$$~X$o      oX]],
[[XO ^+ XXXXXXXXXXXXXXXXXXXXXXX]],
[[XO ^X                      ^!]],
[[XXXXX+XXX+XXXXX+XXX+XXXXX+XXX]],
[[X~XX   XO  +$X   Xo  +$X   XX]],
[[X$XX   X O XXXO oX  oXXX o XX]],
[[X$~+ P Xo  XP+   X O X$+  oXX]],
[[XXXXXXXXXXXXXXXXXXXXXXXXXXXXX]],
}