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

defineTile('.', "CAVEFLOOR", nil, nil, nil, {lite=true})
defineTile('#', "CAVEWALL", nil, nil, nil, {lite=true})
defineTile('+', "CAVEFLOOR", nil, nil, nil, {lite=true})
defineTile('@', "CAVEFLOOR", nil, "FILLAREL", nil, {lite=true})
defineTile('M', "CAVEFLOOR", nil, "CORRUPTOR", nil, {lite=true})

subGenerator{
	x = 0, y = 0, w = 86, h = 50,
	generator = "engine.generator.map.Roomer",
	data = {
		edge_entrances = {4,6},
		nb_rooms = 13,
		rooms = {"random_room"},
		['.'] = "CAVEFLOOR",
		['#'] = "CAVEWALL",
		up = "CAVE_LADDER_UP_WILDERNESS",
		door = "CAVEFLOOR",
		force_tunnels = {
			{"random", {85, 25}, id=-500},
		},
	},
	define_up = true,
}

checkConnectivity({87,25}, "entrance", "boss-area", "boss-area")

return [[
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      #######.######
                                                                                      #####.....####
                                                                                      ###.........##
                                                                                      ##...........#
                                                                                      #............#
                                                                                      #............#
                                                                                      #............#
                                                                                      #......@.....#
                                                                                      #............#
                                                                                      #............#
                                                                                      #............#
                                                                                      #............#
                                                                                      +............#
                                                                                      #............#
                                                                                      #............#
                                                                                      #............#
                                                                                      #............#
                                                                                      #......M.....#
                                                                                      #............#
                                                                                      #............#
                                                                                      ##...........#
                                                                                      ####.......###
                                                                                      #####.....####
                                                                                      #######.######
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############
                                                                                      ##############]]
