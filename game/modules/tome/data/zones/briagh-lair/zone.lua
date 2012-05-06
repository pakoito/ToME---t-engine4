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

return {
	name = "Briagh's Lair",
	level_range = {35, 50},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 140, height = 140,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	min_material_level = 3,
	max_material_level = 5,
	ambient_music = "Suspicion.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.Cavern",
			zoom = 16,
			min_floor = 1000,
			floor = "UNDERGROUND_SAND",
			wall = "SANDWALL_STABLE",
			up = "SAND_LADDER_UP",
			down = "SAND_LADDER_DOWN",
			door = "UNDERGROUND_SAND",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {120, 140},
			guardian = "BRIAGH",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_object = {0, 0},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "SAND_LADDER_UP_WILDERNESS",
			}, },
		},
	},
}
