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

startx = 13
starty = 2 
endx = 2
endy = 5

defineTile("0", "SIGN_CAVE", nil, nil, "TUTORIAL_TIMED0")
defineTile("1", "SIGN_CAVE", nil, nil, "TUTORIAL_TIMED1")
defineTile("2", "SIGN_CAVE", nil, nil, "TUTORIAL_TIMED2")
defineTile("3", "SIGN_CAVE", nil, nil, "TUTORIAL_TIMED3")
defineTile("4", "SIGN_CAVE", nil, nil, "TUTORIAL_TIMED4")
defineTile("5", "SIGN_CAVE", nil, nil, "TUTORIAL_TIMED5")
defineTile("6", "SIGN_CAVE", nil, nil, "TUTORIAL_TIMED6")
defineTile("7", "SIGN_CAVE", nil, nil, "TUTORIAL_TIMED7")
defineTile("8", "FINAL_LESSON", nil, nil, "TUTORIAL_TIMED8")

defineTile("A", "CAVEFLOOR", nil, "FEEBLE_ELF", nil)
defineTile("B", "CAVEFLOOR", nil, "ROOTED_ORC", nil)
defineTile("C", "CAVEFLOOR", nil, "OBSTINATE_ORC", nil)
defineTile("D", "CAVEFLOOR", nil, "RUDE_ORC", nil)
defineTile("E", "CAVEFLOOR", nil, "AVERAGE_TROLL", nil)
defineTile("F", "CAVEFLOOR", nil, "UGLY_TROLL", nil)
defineTile("G", "CAVEFLOOR", nil, "GROSS_TROLL", nil)
defineTile("H", "CAVEFLOOR", nil, "GHASTLY_TROLL", nil)
defineTile("I", "CAVEFLOOR", nil, "FORUM_TROLL", nil)
defineTile("J", "CAVEFLOOR", nil, "PUSHY_ELF", nil)
defineTile("K", "CAVEFLOOR", nil, "BLUSTERING_ELF", nil)
defineTile("M", "CAVEFLOOR", nil, "BREEZY_ELF", nil)

defineTile("-", "LEARN_SPELL_BLEED")
defineTile("_", "LEARN_MIND_CONFUSION")
defineTile("@", "UNLEARN_ALL")

defineTile(".", "CAVEFLOOR", nil, nil, nil)
defineTile("#", "CAVEWALL", nil, nil, nil)
defineTile("L", "LAVA")
defineTile("W", "WALL", nil, nil, nil)
defineTile('<', "CAVE_LADDER_UP")
defineTile('>', "CAVE_LADDER_DOWN")
defineTile("~", "TUTORIAL_WATER", nil, nil, nil)





return [[
####################
####.7.#############
####@#.######<######
####.#6######.######
####8#.######0######
#.>..#.######.######
######5######-######
##.........##.######
##.###.###.##1######
#...#...#...#.######
#.J.#.K.#.M.#...A###
##.###.###.##....###
##.###.###.##...B###
##.###.###.##....###
##.###.###.##...C###
##.###.###.##....###
##.........##...D###
##...._....##....###
##.........##2######
######.######.######
######4######3######
######.######.######
######.........#####
######.........#####
######I.H.G.F.E#####
######.........#####
####################]]
