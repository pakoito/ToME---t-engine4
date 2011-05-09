-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	name = "TestZone!",
	level_range = {1, 50},
	level_scheme = "player",
	max_level = 4,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	all_remembered = true,
	all_lited = true,
--	persistent = "zone",
	no_level_connectivity = true,
	generator =  {
		map = {
			class = "engine.generator.map.Building",
			max_building_w = 5, max_building_h = 5,
			floor = "FLOOR",
			external_floor = "FLOOR",
			wall = "WALL",
			up = "FLAT_UP6",
			down = "FLAT_DOWN4",
			door = "DOOR",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {0, 0},
		},
--[[
		object = {
			class = "engine.generator.object.Random",
			nb_object = {12, 16},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {20, 30},
		},
]]
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS",
			}, },
		},
	},
--[[
	post_process = function(level)
		local Map = require "engine.Map"
		level.background_particle = require("engine.Particles").new("starfield", 1, {width=Map.viewport.width, height=Map.viewport.height})
	end,

	background = function(level, x, y, nb_keyframes)
		local Map = require "engine.Map"
		level.background_particle.ps:toScreen(x, y, true, 1)
	end,
]]
}
