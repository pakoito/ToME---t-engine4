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
endx = 5
endy = 8

defineTile("0", "SIGN_FLOOR", nil, nil, "TUTORIAL_INFORMED1")
defineTile("1", "SIGN_FLOOR", nil, nil, "TUTORIAL_SCALE1")
defineTile("2", "SIGN_FLOOR", nil, nil, "TUTORIAL_SCALE2")
defineTile("3", "SIGN_FLOOR", nil, nil, "TUTORIAL_SCALE3")
defineTile("4", "SIGN_FLOOR", nil, nil, "TUTORIAL_SCALE4")
defineTile("5", "SIGN_FLOOR", nil, nil, "TUTORIAL_SCALE5")
defineTile("6", "SIGN_FLOOR", nil, nil, "TUTORIAL_SCALE6")
defineTile("7", "SIGN_FLOOR", nil, nil, "TUTORIAL_SCALE7")
defineTile("8", "SIGN_FLOOR", nil, nil, "TUTORIAL_SCALE8")
defineTile("9", "SIGN_FLOOR", nil, nil, "TUTORIAL_SCALE9")
defineTile("a", "SIGN_FLOOR", nil, nil, "TUTORIAL_SCALE10")
defineTile("b", "SIGN_FLOOR", nil, nil, "TUTORIAL_SCALE11")
defineTile("c", "SIGN_FLOOR", nil, nil, "TUTORIAL_SCALE12")

defineTile("A", "FLOOR", "PHYSSAVE_BOOTS")
defineTile("B", "FLOOR", "MINDPOWER_AMULET")
defineTile("C", "FLOOR", "ACCURACY_HELM")
defineTile("D", "FLOOR", "MENTALSAVE_RING")
defineTile("t", "TREE", nil, nil, nil)
defineTile("#", "WALL", nil, nil, nil)
defineTile("%", "GLASSWALL", nil, nil, nil)
defineTile("+", "DOOR", nil, nil, nil)
defineTile(".", "FLOOR", nil, nil, nil)
defineTile('$', "FLOOR", {random_filter={type="money"}})
defineTile("o", "FLOOR", nil, "TUTORIAL_ORC", nil)
defineTile("L", "LAVA")
defineTile('>', "DOWN")
defineTile('<', "UP")

defineTile(")", "GRASS", {random_filter={name="ash longbow"}}, nil, nil)
defineTile("s", "GRASS", nil, "TUTORIAL_NPC_MAGE", nil)
defineTile(",", "GRASS", nil, nil, nil)
defineTile("S", "GRASS", nil, {random_filter={type="animal", subtype="snake", max_ood=2}}, nil)
defineTile("T", "GRASS", nil, "TUTORIAL_NPC_TROLL", nil)


defineTile("|", "GRASS", {random_filter={name="elm arrow"}}, nil, nil)


defineTile("~", "TUTORIAL_WATER", nil, nil, nil)

defineTile("j", "GRASS", nil, {random_filter={type="immovable", subtype="jelly", max_ood=2}}, nil)
defineTile(" ", "DEEP_WATER", nil, {random_filter={type="immovable", subtype="jelly", max_ood=2}}, nil)
defineTile("!", "GRASS", {random_filter={name="healing infusion"}}, nil, nil)
defineTile('"', "DEEP_WATER", nil, {random_filter={type="immovable", subtype="jelly", max_ood=2}}, nil)
defineTile("&", "DEEP_WATER", {random_filter={name="shielding rune"}}, nil, nil)


return [[
#############
#<.+0..%o+###
#####..%.####
#..1+..######
#.###########
#.#LLLLL#####
#3#L~~~~#####
#.#L~~~~#####
#4#L~>..#####
#.#L~~~.#####
#5#L~~~c#####
#.#LLL~.#####
#.#####+#####
#.....#b#####
#~~.~~#.#####
#~A.B~#.#####
#~~6~~#.#####
#.....#.#####
###+###a#####
###.###+#####
###7###....D#
###+###.....#
#~~8~~#LLL..#
#~...~#LLL..#
#~.C.~#.....#
#~~.~~#.....#
###+###+#####
###..9...####
#############]]


