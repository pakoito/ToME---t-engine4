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

return {
	name = "Elven Ruins",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 5,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 150, height = 150,
--	all_remembered = true,
--	all_lited = true,
	persistant = "zone",
	generator =  {
		map = {
			class = "engine.generator.map.TileSet",
			tileset = {"5x5/base", "5x5/tunnel", "5x5/windy_tunnel", "5x5/basic_rooms"},
			tunnel_chance = 30,
			center_room = 1,
			['.'] = "FLOOR",
			['#'] = "WALL",
			['+'] = "DOOR",
			["'"] = "DOOR",
			up = "UP",
			down = "DOWN",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20*5, 20*5},
--			guardian = "SHADE_OF_ANGMAR", -- The gardian is set in the static map
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6*5, 9*5},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6*8, 9*8},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS",
			}, },
		},
	},
}
