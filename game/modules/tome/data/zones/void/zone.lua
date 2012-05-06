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
	name = "Void between worlds",
	display_name = function(x, y)
		return "Void between worlds"
	end,
	variable_zone_name = true,
	level_range = {100, 100},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 60, height = 25,
--	all_remembered = true,
	all_lited = true,
	zero_gravity = true,
	no_worldport = true,
	persistent = "zone",
	color_shown = {0.7, 0.6, 0.8, 1},
	color_obscure = {0.7*0.6, 0.6*0.6, 0.8*0.6, 0.6},
	ambient_music = "Through the Dark Portal.ogg",
	min_material_level = 5,
	generator = {
		map = {
			class = "engine.generator.map.Forest",
			floor = "VOID",
			wall = "SPACETIME_RIFT",
			up = "VOID",
			down = "VOID",
			edge_entrances = {4,6},
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {15, 25},
		},
	},

	post_process = function(level)
		local Map = require "engine.Map"
		level.background_particle = require("engine.Particles").new("starfield", 1, {width=Map.viewport.width, height=Map.viewport.height})
	end,

	background = function(level, x, y, nb_keyframes)
		local Map = require "engine.Map"
		level.background_particle.ps:toScreen(x, y, true, 1)
	end,
}
