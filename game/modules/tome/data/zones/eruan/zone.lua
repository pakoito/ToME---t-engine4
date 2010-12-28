-- ToME - Tales of Maj'Eyal
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
	name = "Erúan",
	level_range = {30, 45},
	level_scheme = "player",
	max_level = 5,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	persistant = "zone",
	ambiant_music = "Bazaar of Tal-Mashad.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
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

			nb_rooms = {0,0,0,0,1},
			rooms = {"greater_vault"},
			greater_vaults_list = {"dragon_lair", "lava_island"},
			lite_room_chance = 100,
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 30},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS_FAR_EAST",
			}, },
		},
		[5] = {
			generator = { map = {
				class = "engine.generator.map.Static",
				map = "zones/eruan-last",
			}, },
		},
	},
}
