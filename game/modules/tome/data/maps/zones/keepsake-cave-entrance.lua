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

-- defineTile section
defineTile(".", "GRASS")
defineTile("t", "HARDTREE")
defineTile("*", "FLOWER")
defineTile("<", "GRASS_UP2_UP2")

defineTile(",", "CAVEFLOOR")
defineTile("#", "CAVEWALL")
defineTile("+", "CAVE_DOOR")
defineTile("m", "CAVEFLOOR_CAVE_MARKER")
defineTile("e", "CAVEFLOOR_CAVE_ENTRANCE")
defineTile("d", "CAVEFLOOR_CAVE_DESCRIPTION")
defineTile(">", "CAVE_LADDER_DOWN")
defineTile("W", "CAVEFLOOR", nil, "CORRUPTED_WAR_DOG")
defineTile("C", "CAVEFLOOR", nil, "SHADOW_CASTER")
defineTile("S", "CAVEFLOOR", nil, "SHADOW_STALKER")
defineTile("L", "CAVEFLOOR", nil, "SHADOW_CLAW")

startx = 4
starty = 22

-- addSpot section
addSpot({4, 22}, "level", "up")
addSpot({18, 10}, "level", "down")
addSpot({7, 16}, "berethh", "encounter")
addSpot({20, 4}, "guards", "wardog")
addSpot({21, 4}, "guards", "claw")
addSpot({19, 5}, "guards", "claw")

-- addZone section

-- ASCII map section
return [[
ttttttttt###############
tttt,,tt########,,,,####
ttt,,,,,,e#,,##,,,,,,###
ttt,,,m,,e+,,d,,,,,,,,##
tttt,,,,,e#,##,,,,,,,,##
tttt,,########,,,,,,,,##
ttttt.########,,,,,,,,##
tttt.....tt####,,,,,,###
ttt..ttt.ttttt####+#####
ttt.tt...tttt#####,,####
tt......ttttt####,>,####
ttt........ttt####,#####
ttt......t....tt########
tt......tttt.ttttt###ttt
tt.............ttttttttt
ttt........tt...tttttttt
ttt........tt...tttttttt
ttt.......tt....tttttttt
ttt..........ttttttttttt
tt.....t..tttttttttttttt
ttt......ttttttttttttttt
tt...ttttttttttttttttttt
tttt<ttttttttttttttttttt
tttttttttttttttttttttttt]]