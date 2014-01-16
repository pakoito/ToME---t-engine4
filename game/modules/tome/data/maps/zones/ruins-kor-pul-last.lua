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

defineTile('.', "FLOOR")
defineTile('#', "WALL")
defineTile('+', "DOOR")
defineTile('n', "FLOOR", "NOTE5")
defineTile('s', "FLOOR", nil, "SHADE")

subGenerator{
	x = 0, y = 0, w = 50, h = 43,
	generator = "engine.generator.map.Roomer",
	data = {
		nb_rooms = 10,
		rooms = {"random_room"},
		['.'] = "FLOOR",
		['#'] = "WALL",
		up = "UP",
		door = "DOOR",
		force_tunnels = {
			{"random", {26, 43}, id=-500},
		},
	},
	define_up = true,
}

checkConnectivity({26,44}, "entrance", "boss-area", "boss-area")

return {
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[#########################+########################]],
[[##..............#...#...n....#...#..............##]],
[[#.............#...#...#....#...#...#.............#]],
[[#.........##############################.........#]],
[[#................................................#]],
[[##.......................s......................##]],
[[##################################################]]
}
