-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	name = "Stellar System: Shandral",
	display_name = function(x, y)
		return "Stellar System: Shandral"
	end,
	variable_zone_name = true,
	level_range = {1, 1},
	level_scheme = "player",
	max_level = 1,
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	all_remembered = true,
	all_lited = true,
	zero_gravity = true,
	no_worldport = true,
--	persistent = "zone",
	ambient_music = "Through the Dark Portal.ogg",
	stellar_map = true,
	generator = {
		map = {
			class = "engine.generator.map.Static",
			map = "stellar-system/shandral",
		},
	},

	post_process = function(level)
		local Map = require "engine.Map"
		if core.shader.allow("volumetric") then
			level.starfield_shader = require("engine.Shader").new("starfield", {size={Map.viewport.width, Map.viewport.height}})
		else
			level.background_particle1 = require("engine.Particles").new("starfield_static", 1, {width=Map.viewport.width, height=Map.viewport.height, nb=300, a_min=0.5, a_max = 0.8, size_min = 1, size_max = 3})
			level.background_particle2 = require("engine.Particles").new("starfield_static", 1, {width=Map.viewport.width, height=Map.viewport.height, nb=300, a_min=0.5, a_max = 0.9, size_min = 4, size_max = 8})
		end
	end,

	frames = 0,
	background = function(level, x, y, nb_keyframes)
		level.data.frames = level.data.frames + nb_keyframes

		local Map = require "engine.Map"
		if level.starfield_shader and level.starfield_shader.shad then
			level.starfield_shader.shad:use(true)
			core.display.drawQuad(x, y, Map.viewport.width, Map.viewport.height, 1, 1, 1, 1)
			level.starfield_shader.shad:use(false)
		elseif level.background_particle1 then
			level.background_particle1.ps:toScreen(x, y, true, 1)
			local parx, pary = level.map.mx / (level.map.w - Map.viewport.mwidth), level.map.my / (level.map.h - Map.viewport.mheight)
			level.background_particle2.ps:toScreen(x - parx * 40, y - pary * 40, true, 1)
		end
	end,
}
