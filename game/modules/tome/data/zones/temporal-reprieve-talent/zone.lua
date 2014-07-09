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
	name = "Temporal Reprieve",
	level_range = {1, 100},
	level_scheme = "player",
	max_level = 1,
	actor_adjust_level = function(zone, level, e) return level.source_zone.base_level + e:getRankLevelAdjust() + level.source_level.level-1 + rng.range(-1,2) end,
	width = 15, height = 15,
	all_remembered = true,
	all_lited = true,
	no_worldport = true,
	is_temporal_reprieve = true,
	no_planechange = true,
	ambient_music = {"last"},
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/temporal-reprieve-talent",
		},
	},
	post_process = function(level)
		-- Cosmetic stuff
		local Map = require "engine.Map"
		if core.shader.allow("volumetric") then
			level.starfield_shader = require("engine.Shader").new("starfield", {size={Map.viewport.width, Map.viewport.height}})
		else
			level.background_particle = require("engine.Particles").new("starfield", 1, {width=Map.viewport.width, height=Map.viewport.height})
		end

		game.state:makeWeather(level, 6, {max_nb=2, chance=1, dir=120, speed={1.5, 5.9}, r=0.2, g=0.4, b=1, alpha={0.2, 0.4}, particle_name="weather/grey_cloud_%02d"})

		if not config.settings.tome.weather_effects then return end

		local Map = require "engine.Map"
		level.foreground_particle = require("engine.Particles").new(core.shader.allow("distort") and "temporalsnow" or "snowing", 1, {width=Map.viewport.width, height=Map.viewport.height, r=0.65, g=0.25, b=1, rv=-0.001, gv=0, bv=-0.001, factor=2, dir=math.rad(110+180)})
	end,
	background = function(level, x, y, nb_keyframes)
		local Map = require "engine.Map"
		if level.starfield_shader and level.starfield_shader.shad then
			level.starfield_shader.shad:use(true)
			core.display.drawQuad(x, y, Map.viewport.width, Map.viewport.height, 1, 1, 1, 1)
			level.starfield_shader.shad:use(false)
		elseif level.background_particle then
			level.background_particle.ps:toScreen(x, y, true, 1)
		end
	end,
	foreground = function(level, x, y, nb_keyframes)
		if not config.settings.tome.weather_effects or not level.foreground_particle then return end
		level.foreground_particle.ps:toScreen(x, y, true, 1)
	end,
}
