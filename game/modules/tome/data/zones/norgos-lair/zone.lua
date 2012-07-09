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
	name = "Norgos Lair",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	color_shown = {0.7, 0.7, 0.7, 1},
	color_obscure = {0.7*0.6, 0.7*0.6, 0.7*0.6, 0.6},
	ambient_music = "Woods of Eremae.ogg",
	min_material_level = function() return game.state:isAdvanced() and 3 or 1 end,
	max_material_level = function() return game.state:isAdvanced() and 4 or 2 end,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			edge_entrances = {6,4},
			rooms = {"forest_clearing"},
			['.'] = "ROCKY_GROUND",
			['#'] = {"ROCKY_SNOWY_TREE","ROCKY_SNOWY_TREE2","ROCKY_SNOWY_TREE3","ROCKY_SNOWY_TREE4","ROCKY_SNOWY_TREE5","ROCKY_SNOWY_TREE6","ROCKY_SNOWY_TREE7","ROCKY_SNOWY_TREE8","ROCKY_SNOWY_TREE9","ROCKY_SNOWY_TREE10","ROCKY_SNOWY_TREE11","ROCKY_SNOWY_TREE12","ROCKY_SNOWY_TREE13","ROCKY_SNOWY_TREE14","ROCKY_SNOWY_TREE15","ROCKY_SNOWY_TREE16","ROCKY_SNOWY_TREE17","ROCKY_SNOWY_TREE18","ROCKY_SNOWY_TREE19","ROCKY_SNOWY_TREE20",},
			up = "ROCKY_UP6",
			down = "ROCKY_DOWN4",
			door = "ROCKY_GROUND",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			filters = { {max_ood=2}, },
			guardian = "NORGOS",
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
				up = "ROCKY_UP_WILDERNESS",
			}, },
		},
	},

	post_process = function(level)
		if not config.settings.tome.weather_effects then return end

		local Map = require "engine.Map"
		level.foreground_particle = require("engine.Particles").new("snowing", 1, {width=Map.viewport.width, height=Map.viewport.height})
	end,

	foreground = function(level, x, y, nb_keyframes)
		if not config.settings.tome.weather_effects or not level.foreground_particle then return end
		level.foreground_particle.ps:toScreen(x, y, true, 1)
	end,
}
