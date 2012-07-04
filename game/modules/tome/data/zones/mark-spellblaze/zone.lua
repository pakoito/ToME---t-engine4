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
	name = "Mark of the Spellblaze",
	level_range = {25, 35},
	level_scheme = "player",
	max_level = 2,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = "Broken.ogg",
	min_material_level = 2,
	max_material_level = 3,
	is_mark_spellblaze = true,
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			edge_entrances = {4,6},
			zoom = 4,
			sqrt_percent = 45,
			noise = "fbm_perlin",
			floor = "BURNT_GROUND",
			wall = {"BURNT_TREE1","BURNT_TREE2","BURNT_TREE3","BURNT_TREE4","BURNT_TREE5","BURNT_TREE6","BURNT_TREE7","BURNT_TREE8","BURNT_TREE9","BURNT_TREE10","BURNT_TREE11","BURNT_TREE12","BURNT_TREE13","BURNT_TREE14","BURNT_TREE15","BURNT_TREE16","BURNT_TREE17","BURNT_TREE18","BURNT_TREE19","BURNT_TREE20",},
			up = "BURNT_UP4",
			down = "BURNT_DOWN6",
			do_ponds =  {
				nb = {0, 2},
				size = {w=25, h=25},
				pond = {{0.6, "LAVA"}, {0.8, "LAVA"}},
			},
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "BURNT_UP_WILDERNESS",
			}, },
		},
		[2] = {
			width = 65, height = 50,
			generator = { map = {
				class = "engine.generator.map.Static",
				map = "zones/mark-spellblaze-last",
			}, },
		},
	},
}
