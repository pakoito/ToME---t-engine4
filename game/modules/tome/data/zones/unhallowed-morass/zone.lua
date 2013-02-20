-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	name = "Unhallowed Morass",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	tier1 = true,
	persistent = "zone",
	ambient_music = "Suspicion.ogg",
	max_material_level = 2,
	color_shown = {0.7, 0.6, 0.8, 1},
	color_obscure = {0.7*0.6, 0.6*0.6, 0.8*0.6, 0.6},

	generator =  {
		map = {
			class = "engine.generator.map.Cavern",
			zoom = 25,
			min_floor = 900,
			floor = "VOID",
			wall = "SPACETIME_RIFT",
			up = "VOID",
			down = "RIFT",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			filters = { {max_ood=2}, },
			guardian = "WEAVER_QUEEN",
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

	post_process = function(level)
		local Map = require "engine.Map"
		level.background_particle = require("engine.Particles").new("starfield", 1, {width=Map.viewport.width, height=Map.viewport.height})

		game.state:makeWeather(level, 6, {max_nb=12, chance=1, dir=120, speed={1.5, 5.9}, r=0.2, g=0.4, b=1, alpha={0.2, 0.4}, particle_name="weather/grey_cloud_%02d"})

		if not config.settings.tome.weather_effects then return end

		local Map = require "engine.Map"
		level.foreground_particle = require("engine.Particles").new("snowing", 1, {width=Map.viewport.width, height=Map.viewport.height, r=0.65, g=0.25, b=1, rv=-0.001, gv=0, bv=-0.001, factor=2, dir=math.rad(110+180)})
	end,

	background = function(level, x, y, nb_keyframes)
		local Map = require "engine.Map"
		level.background_particle.ps:toScreen(x, y, true, 1)
	end,

	foreground = function(level, x, y, nb_keyframes)
		if not config.settings.tome.weather_effects or not level.foreground_particle then return end
		level.foreground_particle.ps:toScreen(x, y, true, 1)
	end,
}
