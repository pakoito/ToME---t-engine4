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

quickEntity('>', {always_remember = true, type="floor", subtype="grass", show_tooltip=true, name="Passage to the caverns", desc="A dark hole in the mountain", display='>', color=colors.GREY, notice = true, change_level=2, change_zone="valley-moon-caverns", keep_old_lev=true, iamge="terrain/grass.png", add_mos={{image="terrain/stair_down.png"}}})
defineTile('.', "GRASS")
defineTile('~', "POISON_DEEP_WATER")
defineTile('"', "GRASS", nil, nil, nil, {summon_limmir=true})
defineTile('&', "PORTAL_DEMON")
defineTile('T', "TREE")
defineTile('#', "MOUNTAIN_WALL")
defineTile('M', "MOONSTONE")

addSpot({34, 1}, "portal", "demon")
addSpot({39, 7}, "portal", "demon")
addSpot({47, 11}, "portal", "demon")

startx = 45
starty = 1

return [[
##################################################
##################################&..........>####
####....T.........T~~~~~~~~T....####T....T.....###
####..........T...T~~~~~~.......######.......T.###
####................~~~TT.....#####.....T......###
####...T.....TT......~~~...............T##.....###
####.........T.......~~~.............######.TT.###
###...................~~~T.........####&.....T####
##................T...~~~~...........#####...#####
##.....TTT..........~~~~....TTTT.......###...T.###
##T............~~~~~~~.........TT........#...T.###
##T............~~~~~~......TT..................&##
###.........TT..~~~~........T.........##......####
###....TT....TT.~~~~~............T.....####.######
###............TT~~~~~~........TTTTT....######..##
###..............~~~~~~TT........TT......######.##
###......TTT....~~~~~~TTTT......TT.......T......##
###......T...~~~~~~~~~~~~~~~~~~..........TTT...###
#T#..........~~~~~~~~~~~~~~~~~~~~~.......TT....###
###........~~~~~~~~~~~~~~~~~~~~~~~~.......TT...###
###........~~~~~~~~~~~~~~~~~~~~~~~~~...........###
###........~~~~~~~~~~~"""~~~~~~~~~~~~~........T###
###..TT...~~~~~~~~~~~"""""""~~~~~~~~~~....T.T..###
###.TT...~~~~~~~~~~~~"""MMM""~~~~~.~~.......TT####
###......~~~~~~~~~~~~"""MMMM""~~~~............####
###............~~~~~~""".MM"""~~~~~....TT.....####
###.TTT.......~~~~~~~"""""""""~~~~~~~.........####
####..T......~~~~~~~~~~"""""""~~~~~~~...........##
####.........~~~~~~~~~~~""""""~~~~~~~.TTTT..TT..##
#####.........~~~~~~~~~~"""~~~~~~~~~~......TT...##
#####..........~~~~~~~~~~~~~~~~~~~~~~~~~........##
#####.....T....~~~~~~~~~~~~~~~~~~~~~~~~~........##
####......T....~~~~~~~~~~~~~~~~~~~~~~~~.......T###
####T..........~~~~~~~~~~~~~~~~~~~~~~~........T###
###.............~~~~~~~~~~~~~~~~~~~~~.....T...####
###...............~~~~~~~~~~~~~~~~~~~.........####
##...................~~~~~~~~~~~~~~~.........T####
##..T.....T...........~~~~~~~...........T..TT.####
##....................~~~~~~..........TTT...T.####
##...........T........................T........###
##.....T.....T................T................###
##....................................T.........##
##................T..........T........T....T....##
##...T................................TT......T..#
###.........T................TT...............T..#
###...................T.......T............T...###
####.........................................#####
#######.........T........T.............###########
#####################........#####################
##################################################]]
