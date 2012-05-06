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
	name = "Fearscape",
	level_range = {35, 45},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 65, height = 65,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	no_worldport = true,
	is_demon_plane = true,
	ambient_music = "Straight Into Ambush.ogg",
	min_material_level = 3,
	max_material_level = 5,
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			edge_entrances = {2,8},
			zoom = 3,
			sqrt_percent = 30,
			noise = "fbm_perlin",
			floor = "LAVA_FLOOR",
			wall = "LAVA_WALL",
			up = "LAVA_FLOOR",
			down = "LAVA_FLOOR",
			do_ponds =  {
				nb = {2, 3},
				size = {w=25, h=25},
				pond = {{0.6, "LAVA"}, {0.8, "LAVA"}},
			},
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {40, 40},
			guardian = "DRAEBOR",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {12, 15},
		},
	},
	on_enter = function(lev, old_lev, newzone)
		if newzone then game.player:learnLore("fearscape-entry") end
	end,
}
