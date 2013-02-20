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

startx = 1
starty = 1 

addSpot({22, 16}, "door", "sealed")

defineTile("0", "SIGN_CAVE", nil, nil, "TUTORIAL_TIER0")
defineTile("1", "SIGN_CAVE", nil, nil, "TUTORIAL_TIER1")
defineTile("2", "SIGN_FLOOR", nil, nil, "TUTORIAL_TIER2")
defineTile("3", "SIGN_CAVE", nil, nil, "TUTORIAL_TIER3")
defineTile("4", "SIGN_FLOOR", nil, nil, "TUTORIAL_TIER4")
defineTile("5", "SIGN_FLOOR", nil, nil, "TUTORIAL_TIER5")
defineTile("6", "SIGN_FLOOR", nil, nil, "TUTORIAL_TIER6")
defineTile("7", "SIGN_FLOOR", nil, nil, "TUTORIAL_TIER7")
defineTile("8", "SIGN_CAVE", nil, nil, "TUTORIAL_TIER8")
defineTile("9", "SIGN_FLOOR", nil, nil, "TUTORIAL_TIER9")
defineTile("a", "SIGN_CAVE", nil, nil, "TUTORIAL_TIER10")
defineTile("b", "COMBAT_STATS_DONE", nil, nil, "TUTORIAL_TIER11")
defineTile("c", "SIGN_SOLID_FLOOR", nil, nil, "TUTORIAL_TIER12")

defineTile('&', "PORTAL_BACK_2")
defineTile('<', "CAVE_LADDER_UP")
defineTile("_", "LEARN_SPELL_KB")
defineTile("^", "LEARN_SPELL_BLINK")
defineTile(",", "FLOOR", nil, nil, nil)
defineTile("+", "DOOR", nil, nil, nil)
defineTile(".", "CAVEFLOOR", nil, nil, nil)
defineTile("#", "CAVEWALL", nil, nil, nil)
defineTile("W", "WALL", nil, nil, nil)
defineTile("S", "SOLID_WALL", nil, nil, nil)
defineTile("*", "SOLID_DOOR", nil, nil, nil)
defineTile("'", "SOLID_FLOOR", nil, nil, nil)
defineTile('$', "SOLID_FLOOR", {random_filter={type="money"}})

defineTile("A", "CAVEFLOOR", nil, "TUT_SPIDER_1", nil)
defineTile("B", "CAVEFLOOR", nil, "TUT_SPIDER_2", nil)
defineTile("C", "CAVEFLOOR", nil, "TUT_SPIDER_3", nil)
defineTile("D", "CAVEFLOOR", nil, "BORED_ELF_1", nil)
defineTile("E", "CAVEFLOOR", nil, "BORED_ELF_2", nil)
defineTile("F", "CAVEFLOOR", nil, "BORED_ELF_3", nil)
defineTile("G", "FLOOR", nil, "ACCURACY_ORC_2", nil)
defineTile("H", "FLOOR", nil, "ACCURACY_ORC_5", nil)

defineTile("~", "TUTORIAL_WATER", nil, nil, nil)

return [[
#######################
#<#####################
#.#####################
#0#####################
#.#####################
#_#####################
#.#######SSSSSSSSSSSS##
#...A...#S$*''''''*$S##
#.......#SSS''~~''SSS##
#1..B...#S'''~~~~'''S##
#.......#S''''$~~~''S##
#...C...#S'''~~~~'''S##
#.......#SSS'~~~''SSS##
##WW+WW##S$*'b'~''*$S##
##W,2,W##SSSSS*SSSSSS##
##W,,,W#######a########
##WW+WW#######.########
###.^.##WWWWWW+W#....##
###...##WH,,9,,W#.WW+WW
####3###W,,,,,,W#.W,7,W
####.###W,,,G,,+8.W,6,W
##WW+WW#WWWWWWWW##W,5,W
##W,4,W###########WW+WW
##W,,,W..............##
##WW+WW.#.###.###.#####
####..............#####
#########.###.###.#####
#########D###E###F#####
#########.###.###.#####
#######################]]
