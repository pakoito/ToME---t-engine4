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

defineTile('<', "WATER_UP")
defineTile(' ', "WATER_FLOOR")
defineTile('+', "WATER_DOOR")
defineTile('#', "WATER_WALL")
defineTile('^', "WATER_FLOOR", nil, nil, {random_filter={}})
defineTile('M', "WATER_FLOOR", nil, {random_filter={}})
defineTile('@', "WATER_FLOOR", nil, "SLASUL")

startx = 15
starty = 0

return [[
###############<##############
##^  #     #### ####     #  ^#
## #M# ### #### #### ### #M# #
##M# # ###  MM # MM  ### # #M#
## #   #################   # #
## #####               ##### #
##    ^+^   M     M   ^+^    #
########               #######
###    ########+########    ##
##             M             #
##   #####################   #
## M # M ###   M   ### M # M #
##   #MMM##         ##MMM#   #
##   #   #M         M#   #   #
###^###+##     @     ##+###^##
###^###^##           ##^###^##
##  ### ##M         M## ###  #
##       ##         ##       #
##       ###  MMM  ###       #
##       ######+######       #
##  ^#^      M#M#M      ^#^  #
##  ###      M#^#M      ###  #
##  ^#^      M#M#M      ^#^  #
##       ######+######       #
##       # ^       ^ #       #
##+####### ######### #######+#
## ####### ######### ####### #
## ####### ######### ####### #
##         #########         #
##############################]]
