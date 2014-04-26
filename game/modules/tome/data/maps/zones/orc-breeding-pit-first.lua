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

defineTile("#", "UNDERGROUND_TREE")
defineTile(".", "UNDERGROUND_FLOOR")
defineTile("<", "UNDERGROUND_LADDER_UP")
defineTile("M", "UNDERGROUND_FLOOR", nil, "THE_MOUTH")

startx = 0
starty = 11
endx = 18
endy = 11

defineTile("#", "WALL")
defineTile("~", "FLOOR", "BREEDING_HISTORY1")
defineTile("o", "FLOOR", nil, "HILL_ORC_WARRIOR")
defineTile("<", "UP_WILDERNESS")
defineTile("+", "DOOR")
defineTile(">", "DOWN")
defineTile("a", "FLOOR", nil, "HILL_ORC_ARCHER")
defineTile(".", "FLOOR")

-- addSpot section

-- addZone section

-- ASCII map section
return [[
#########################
#########################
#########################
#########################
#########################
#########################
#########################
#########aa##############
#####......##############
#####......##############
#####.....o####...~######
<.........o+......>######
<.........o+......>######
#####.....o####....######
#####.....o##############
#####......##############
#########aa##############
#########################
#########################
#########################
#########################
#########################
#########################
#########################
#########################]]