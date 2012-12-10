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

startx = 48
starty = 48

-- defineTile section
defineTile("3", "LORE3")
defineTile("#", "WALL")
defineTile("4", "LORE4")
defineTile("$", "OLD_FLOOR", {random_filter={add_levels=5,ego_chance=70}})
defineTile("%", "OLD_FLOOR", {random_filter={add_levels=5,unique=true,not_properties={"lore"}}})
defineTile("&", "OLD_WALL")
defineTile("*", "PORTAL")
defineTile("+", "DOOR")
defineTile("<", "UP_WILDERNESS")
defineTile(">", "INFINITE")
defineTile(".", "OLD_FLOOR")
defineTile("1", "LORE1")
defineTile("!", "GENERIC_LEVER_DOOR")
defineTile("2", "LORE2")
defineTile(" ", "OLD_FLOOR", nil, {random_filter={random_elite={name_scheme="#rng# the Guardian", on_die=function(self)
	local spot = game.level:pickSpotRemove{type="portal", subtype="portal"}
	if spot then
		game.level.map(spot.x, spot.y, engine.Map.TERRAIN).orb_allowed = true
		require("engine.ui.Dialog"):simplePopup("Guardian", "You can ear a magical trigger firing off.")
	end
end}, add_levels=5}})

-- addSpot section
addSpot({18, 11}, "portal", "portal")
addSpot({19, 11}, "portal", "portal")
addSpot({20, 11}, "portal", "portal")
addSpot({21, 8}, "door", "sealed")
addSpot({22, 11}, "portal", "portal")
addSpot({23, 11}, "portal", "portal")
addSpot({24, 11}, "portal", "portal")

-- addZone section
addZone({16, 0, 26, 8}, "no-teleport", "no-teleport")

-- ASCII map section
return [[
################&&&&&>&&&&&#######################
################&$$.....$$&#######################
################&$$.....$$&#######################
################&$$..%..$$&#######################
################&$$..4..$$&#######################
################&.........&#######################
################&&.......&&###########.......#####
#################&&.....&&############.......#####
##################&&&!&&&######......+.... ..#####
######..#############.#######...######.......#####
#####.....#######.........###.########.......#####
####.......######.***.***.###.####################
####...#...+...##.........###.####################
### ..#....###.######.#######.####################
###..#....####.######.######..####################
####....######.######.######.#####################
####..########.######.######.#####################
##############.######.######.#####################
##############......+.+......#####################
#####################.############################
#####################.############################
################....#.#....#######################
################....#.#....#######################
#############.......+.+........###################
#.....#######.##....#.#....###.###################
#......######.##....#.#....###.#######.....#######
#.&&&....####.#######.########.######........#####
# &&&&........#######.########.........&&&&.. ####
#.&&&....####.#######.########.######........#####
#......######.#######.########.#######.....#######
#.....#######.###...#.#...####.###################
#############.###...#.#...####.###################
#############.......+.+........##############..###
#################...#.#...##################....##
#################...#.#...#############....... .##
##...################.#############.....#####...##
#.....###############.############..#########..###
#.. ..###############.############.###############
#.....###############.###########2.###############
##.##################.###########..###############
##.#...#...#....#####.###########.################
##.#.#.#.#.#.##.#####.###########+#########....###
##.#.#.#.#.#..#..####.########......#######....###
##.#.#.#.#.##.##.###...#######......#######....###
#..#.#.#.#..#..#...+.3.#######..&&..#######....###
#.##.#.#.##.##.#####...+........&&..+..........###
#.#..#.#..#....#####...#######......##############
#.#.##.##.####################......#########1####
#...##....####################......+...........<#
##################################################]]