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
	name = "Paths of the Dead",
	level_range = {1, 8},
	level_scheme = "player",
	max_level = 8,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return 1 + zone.max_level - (zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2)) end,
	width = 50, height = 50,
--	all_remembered = true,
--	all_lited = true,
	persistant = "zone",
	ambiant_music = "Dark Secrets.ogg",
	no_level_connectivity = true,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			force_last_stair = true,
			nb_rooms = 10,
			rooms = {"simple", "pilar", {"money_vault",5}},
			lite_room_chance = 100,
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 30},
			filters = { {max_ood=2}, },
			guardian = "HALF_BONE_GIANT", guardian_level = 1,
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
			filters = { {type="potion" }, {type="potion" }, {type="potion" }, {type="scroll" }, {max_ood=7}, {max_ood=7} }
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
				up = "UP_WILDERNESS",
			}, },
		},
		[8] = {
			generator = { map = {
				class = "engine.generator.map.Static",
				map = "zones/paths-of-the-dead-last",
			}, },
		},
	},
}
