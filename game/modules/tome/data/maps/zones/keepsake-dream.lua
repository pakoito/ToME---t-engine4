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

-- defineTile section
defineTile(".", "GRASS")
defineTile("t", "HARDTREE")
defineTile("=", "STEW")
defineTile("*", "FLOWER")
defineTile("d", "GRASS_DREAM")
defineTile("h", "GRASS_INCHATE")
defineTile("n", "GRASS", "BANDERS_NOTES")
defineTile("a", "GRASS", "IRON_ACORN_BASIC")
defineTile("w", "GRASS_CARAVAN")
defineTile("M", "GRASS", nil, "CARAVAN_MERCHANT")
defineTile("G", "GRASS", nil, "CARAVAN_GUARD")
defineTile("P", "GRASS", nil, "CARAVAN_PORTER")

startx = 10
starty = 1

-- addSpot section

-- addZone section

-- ASCII map section
return [[
tttttttttttttttttttttttt
tttttttttt.ttttttttttttt
tttttttttt.hh.tttttttttt
tttttttttttttntttttttttt
ttttttttttttthtttttttttt
tttttttttttttatttttttttt
ttttttttttttthtttttttttt
ttttttttt.hhh.tttttttttt
tttttttttwttttt...tttttt
ttttt........*......tttt
ttt.....*.....G...*.tttt
tttt........M=.....*.ttt
ttttt...*....M*......ttt
tttttt...............ttt
ttttt...........*...tttt
tt.....*.............ttt
tt.*...G.G.*.......ttttt
ttt....P=......*......tt
tttt..**M.....M......ttt
tttt.........M=....ttttt
ttttt..P..*....P..tttttt
tttttt.......tt..ttttttt
ttttttt...tttttttttttttt
tttttttttttttttttttttttt]]
