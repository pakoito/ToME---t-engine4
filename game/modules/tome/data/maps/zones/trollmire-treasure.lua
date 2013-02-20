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

-- defineTile section
defineTile("$", "GRASS", {random_filter={type="money"}})
defineTile("*", "GRASS", {random_filter={type="gem"}})
defineTile("<", "GRASS_UP4")
defineTile(".", "GRASS")
defineTile("=", "STEW")
defineTile("@", "GRASS", nil, "TROLL_BILL")
defineTile("t", "HARDTREE")
defineTile("T", "GRASS", nil, {random_filter={type="giant", subtype="troll"}})
defineTile("!", "ROCK_VAULT")

startx = 0
starty = 9

-- addSpot section

-- addZone section

-- ASCII map section
return [[
tttttttttttttttttttt
tttttttttttttttttttt
ttttttttttt.tttttttt
ttttttttttt..ttttttt
ttttttttttt..ttttttt
tttttt.ttttT.ttttttt
ttttt$$$.......ttttt
tttt.$$$.......ttttt
ttttt.@=........tttt
<...t***........Tttt
ttt.t***........tttt
ttt.t.t.........tttt
ttt.tttt........tttt
ttt.tttttt......Tttt
tttTtttttt......tttt
ttt.ttttt.....tttttt
ttt.tt.tt..tt.tttttt
tt......!Ttttttttttt
tttttttttttttttttttt
tttttttttttttttttttt]]
