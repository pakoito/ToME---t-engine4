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

defineTile('<', "UP")
defineTile(' ', "FLOOR")
defineTile('+', "DOOR")
defineTile('#', "WALL")
defineTile('$', "FLOOR", "MONEY_SMALL")
defineTile('*', "FLOOR", "MONEY_BIG")

defineTile('&', "FAR_EAST_PORTAL")
defineTile('!', "CFAR_EAST_PORTAL")

defineTile('O', "FLOOR", nil, "GOLBUG")
defineTile('a', "FLOOR", nil, "ORC_ARCHER")
defineTile('o', "FLOOR", nil, "ORC")
defineTile('f', "FLOOR", nil, "ORC_FIRE_WYRMIC")
defineTile('i', "FLOOR", nil, "ORC_ICE_WYRMIC")

startx = 0
starty = 13

return [[
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#####        ##########################################################
####               a###################################################
#####                ############a            a########################
######   ###          ###########              ########################
####     ###f          ##########              ########a  #############
###      ###      #    ##########              ######       ###########
###               ###  ##########             f#####   &&&   ##########
<    o            ###o +++++                  O+++++   &!&   ##########
###               ##   ##########             i#####   &&&   ##########
####        ###        ##########              ######       ###########
####        ###i       ##########              ########a  #############
#####       ###       ###########              ########################
######              a############a            a########################
########           ####################################################
##########    #########################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################]]
