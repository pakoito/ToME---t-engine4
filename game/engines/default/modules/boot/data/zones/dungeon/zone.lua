-- ToME - Tales of Middle-Earth
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

return {
	name = "Forest",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 5,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	levels = {
		[1] = {
			generator =  {
				map = {
					class = "engine.generator.map.Forest",
					edge_entrances = {4,6},
					zoom = 4,
					sqrt_percent = 30,
					noise = "fbm_perlin",
					floor = function() if rng.chance(20) then return "FLOWER" else return "GRASS" end end,
					wall = "TREE",
					up = "GRASS",
					down = "GRASS",
					do_ponds =  {
						nb = {0, 2},
						size = {w=25, h=25},
						pond = {{0.6, "DEEP_WATER"}, {0.8, "DEEP_WATER"}},
					},
				},
				actor = {
					class = "engine.generator.actor.Random",
					nb_npc = {20, 30},
				},
			},
		},
		[2] = {
			generator =  {
				map = {
					class = "engine.generator.map.Roomer",
					nb_rooms = 10,
					rooms = {"random_room"},
					lite_room_chance = 100,
					['.'] = "FLOOR",
					['#'] = "WALL",
					up = "FLOOR",
					down = "FLOOR",
					door = "DOOR",
				},
				actor = {
					class = "engine.generator.actor.Random",
					nb_npc = {20, 30},
				},
			},
		},
		[3] = {
			generator =  {
				map = {
					class = "engine.generator.map.Cavern",
					zoom = 14,
					min_floor = 500,
					floor = "CRYSTAL_FLOOR",
					wall = {"CRYSTAL_WALL","CRYSTAL_WALL2","CRYSTAL_WALL3","CRYSTAL_WALL4","CRYSTAL_WALL5","CRYSTAL_WALL6","CRYSTAL_WALL7","CRYSTAL_WALL8","CRYSTAL_WALL9","CRYSTAL_WALL10","CRYSTAL_WALL11","CRYSTAL_WALL12","CRYSTAL_WALL13","CRYSTAL_WALL14","CRYSTAL_WALL15","CRYSTAL_WALL16","CRYSTAL_WALL17","CRYSTAL_WALL18","CRYSTAL_WALL19","CRYSTAL_WALL20",},
					up = "CRYSTAL_FLOOR",
					down = "CRYSTAL_FLOOR",
					door = "CRYSTAL_FLOOR",
				},
				actor = {
					class = "engine.generator.actor.Random",
					nb_npc = {20, 30},
				},
			},
		},
	},
}
