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

startx = 4
starty = 15
endx = 3
endy = 9

addSpot({22, 16}, "door", "sealed")

defineTile("0", "SIGN_CAVE", nil, nil, "TUTORIAL_CALC0")
defineTile("1", "SIGN_CAVE", nil, nil, "TUTORIAL_CALC1")
defineTile("2", "SIGN_CAVE", nil, nil, "TUTORIAL_CALC2")
defineTile("3", "SIGN_CAVE", nil, nil, "TUTORIAL_CALC3")
defineTile("4", "SIGN_CAVE", nil, nil, "TUTORIAL_CALC4")
defineTile("5", "SIGN_CAVE", nil, nil, "TUTORIAL_CALC5")
defineTile("6", "SIGN_CAVE", nil, nil, "TUTORIAL_CALC6")
defineTile("7", "SIGN_CAVE", nil, nil, "TUTORIAL_CALC7")
defineTile("8", "SIGN_CAVE", nil, nil, "TUTORIAL_CALC8")
defineTile("9", "SIGN_CAVE", nil, nil, "TUTORIAL_CALC9")
defineTile("a", "SIGN_CAVE", nil, nil, "TUTORIAL_CALC10")
defineTile("b", "SIGN_CAVE", nil, nil, "TUTORIAL_CALC11")

defineTile("A", "CAVEFLOOR", nil, "PACIFIST_ORC", nil)
defineTile("B", "CAVEFLOOR", nil, "PACIFIST_ORC_2", nil)
defineTile("C", "CAVEFLOOR", nil, "REGENERATING_ORC", nil)
defineTile("D", "CAVEFLOOR", nil, "FEEBLE_ELF", nil)
defineTile("E", "CAVEFLOOR", nil, "ROOTED_ORC", nil)
defineTile("F", "CAVEFLOOR", nil, "RUDE_ORC", nil)
defineTile("G", "CAVEFLOOR", nil, "OBSTINATE_ORC", nil)
defineTile("H", "CAVEFLOOR", nil, "PUSHY_ORC", nil)

defineTile("-", "LEARN_PHYS_KB")
defineTile("_", "LEARN_SPELL_KB")
defineTile("=", "LEARN_MIND_KB")
defineTile("^", "LEARN_SPELL_BLINK")
defineTile("*", "LEARN_MIND_FEAR")
defineTile("@", "UNLEARN_ALL")
defineTile("!", "LOCK", nil, nil, nil)
defineTile("+", "DOOR", nil, nil, nil)
defineTile(".", "CAVEFLOOR", nil, nil, nil)
defineTile("#", "CAVEWALL", nil, nil, nil)
defineTile("L", "LAVA")
defineTile("W", "WALL", nil, nil, nil)
defineTile("%", "GLASSWALL", nil, nil, nil)
defineTile(",", "FLOOR", nil, nil, nil)
defineTile('$', "FLOOR", {random_filter={type="money"}})
defineTile('<', "CAVE_LADDER_UP")
defineTile('>', "CAVE_LADDER_DOWN")
defineTile("~", "TUTORIAL_WATER", nil, nil, nil)





return [[
###############################
#####.........H.##.....##.....#
######.###...#.###^...*##-._.=#
###....#######.###.....##.....#
###..a.....G.#.#####.######.###
###....##..#...####...#####.###
###b##.#######......9..E....###
###.##.#..####.####...#####8###
###@##....F....############.###
###>####..######...#####WWW+WWW
###.########.2...B.3.4.#W~~.~~W
############.###...###.#W~~.~~W
#~~~~~~~####.#########5#W~~7~~W
#~~~~~~~####1##~~~~##...W.....W
#~~...~~###...#-......C.W.....W
#~~.<.0.....A.#~~~~##...W.....W
#~~...~~###...#######W!WW.###.W
#~~~~~~~#############W6WWC###DW
#~~~~~~~#############W........W
#####################WWWWWWWWWW]]
