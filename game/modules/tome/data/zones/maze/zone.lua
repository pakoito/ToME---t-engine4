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
	name = "The Maze",
	level_range = {7, 12},
	level_scheme = "player",
	max_level = 7,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 40, height = 40,
--	all_remembered = true,
--	all_lited = true,
	persistant = "zone",
	ambiant_music = "The Ancients.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.Maze",
			up = "UP",
			down = "DOWN",
			wall = "OLD_WALL",
			floor = "OLD_FLOOR",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 30},
			guardian = "NIMISIL",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {4, 6},
			filters = { {type="potion" }, {type="potion" }, {type="potion" }, {type="scroll" }, {}, {} }
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {9, 15},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS",
			}, },
		},
		[7] = {
			generator = { map = {
				force_last_stair = true,
				down = "QUICK_EXIT",
			}, },
		},
	},
}
