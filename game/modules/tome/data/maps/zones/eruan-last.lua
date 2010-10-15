-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

defineTile('.', "SAND")
defineTile('#', "PALMTREE")
defineTile('~', "DEEP_WATER")
defineTile('&', "MOUNT_DOOM_PORTAL")
defineTile('s', "SAND", nil, "SUN_PALADIN_GUREN")

subGenerator{
	x = 0, y = 0, w = 50, h = 43,
	generator = "engine.generator.map.Forest",
	data = {
		edge_entrances = {8,2},
		zoom = 6,
		sqrt_percent = 40,
		noise = "fbm_perlin",
		floor = "SAND",
		wall = "PALMTREE",
		up = "UP",
		down = "DOWN",
		do_ponds =  {
			nb = {0, 2},
			size = {w=25, h=25},
			pond = {{0.6, "DEEP_WATER"}, {0.8, "SHALLOW_WATER"}},
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
[[.....................########.....................]],
[[..#.................##~~###~#.....#...............]],
[[.....#............#..#~~~~~~##.........#...#....#.]],
[[...#........#.......##~~&&&~~##....#.....#..#.....]],
[[.........#..........#~~~&&&s.............#....#...]],
[[..............#.....#~~~&&&~~~#...#...#........#..]],
[[....................###~~~~~~##...................]]
}
