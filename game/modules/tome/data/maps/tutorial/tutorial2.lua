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

startx = 0
starty = 1
endx = 5
endy = 14

defineTile("0", "SIGN", nil, nil, "TUTORIAL_INTRO_MECHANICS_GUIDE")
defineTile("1", "SIGN", nil, nil, "TUTORIAL_STATS1")
defineTile("2", "SIGN", nil, nil, "TUTORIAL_STATS2")
defineTile("3", "SIGN", nil, nil, "TUTORIAL_STATS3")
defineTile("4", "SIGN", nil, nil, "TUTORIAL_STATS4")
defineTile("5", "SIGN", nil, nil, "TUTORIAL_STATS5")
defineTile("6", "SIGN", nil, nil, "TUTORIAL_STATS6")
defineTile("7", "SIGN", nil, nil, "TUTORIAL_STATS7")
defineTile("a", "SIGN", nil, nil, "TUTORIAL_STATS7.1")
defineTile("8", "SIGN", nil, nil, "TUTORIAL_STATS8")
defineTile("9", "SIGN_FLOOR", nil, nil, "TUTORIAL_STATS9")

defineTile("#", "TREE", nil, nil, nil)
defineTile("W", "WALL", nil, nil, nil)
defineTile("%", "GLASSWALL", nil, nil, nil)
defineTile("+", "DOOR", nil, nil, nil)
defineTile(",", "FLOOR", nil, nil, nil)
defineTile('$', "FLOOR", {random_filter={type="money"}})
defineTile('>', "DOWN")
defineTile(".", "GRASS", nil, nil, nil)
defineTile("'", "SQUARE_GRASS", nil, nil, nil)
defineTile("~", "TUTORIAL_WATER", nil, nil, nil)

return [[
########
..0.####
###.####
###1####
#~~'~~##
#~~'~~##
#~~2~~##
#~~'~~##
#~~3~~##
#~~'~~##
###4####
###.####
###.####
WWW+WWW#
W$%5%>W#
W,%.%,W#
W$%6%$W#
W,%.%9W#
W$%7%$W#
W,%a%,W#
W...8.W#
WWWWWWW#]]
