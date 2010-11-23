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
	name = "Old Forest",
	level_range = {7, 16},
	level_scheme = "player",
	max_level = 7,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	persistant = "zone",
	color_shown = {0.5, 0.5, 0.5, 1},
	color_obscure = {0.5*0.6, 0.5*0.6, 0.5*0.6, 1},
	ambiant_music = "Woods of Eremae.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			edge_entrances = {6,4},
			rooms = {"forest_clearing", {"lesser_vault",8}},
			rooms_config = {forest_clearing={pit_chance=5, filters={{type="insect", subtype="ant"}, {type="insect"}, {type="animal", subtype="snake"}, {type="animal", subtype="canine"}}}},
			lesser_vaults_list = {"honey_glade", "troll-hideout", "mage-hideout", "thief-hideout", "plantlife", "mold-path"},
			['.'] = "GRASS",
			['#'] = {"TREE","TREE2","TREE3","TREE4","TREE5","TREE6","TREE7","TREE8","TREE9","TREE10","TREE11","TREE12","TREE13","TREE14","TREE15","TREE16","TREE17","TREE18","TREE19","TREE20",},
			up = "UP",
			down = "DOWN",
			door = "GRASS",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 30},
			guardian = "WRATHROOT",
		},
		object = {
			class = "engine.generator.object.Random",
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
			filters = { {} }
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
	},

	post_process = function(level)
		local Map = require "engine.Map"
		level.foreground_particle = require("engine.Particles").new("raindrops", 1, {width=Map.viewport.width, height=Map.viewport.height})

		-- Place a lore note on each level
		game:placeRandomLoreObject("NOTE"..level.level)
	end,

	foreground = function(level, x, y, nb_keyframes)
		local Map = require "engine.Map"
		for i = 1, nb_keyframes do level.foreground_particle:update() end
		level.foreground_particle.ps:toScreen(x, y, true, 1, nb_keyframes)
	end,
}
