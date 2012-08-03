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
	name = "Dreamscape",
	level_range = {1, 100},
	level_scheme = "player",
	max_level = 1,
	actor_adjust_level = function(zone, level, e) return level.source_zone.base_level + e:getRankLevelAdjust() + level.source_level.level-1 + rng.range(-1,2) end,
	width = 20, height = 20,
	all_remembered = true,
	all_lited = true,
	no_worldport = true,
	is_dream_scape = true,
	no_planechange = true,
	ambient_music = "Straight Into Ambush.ogg",
	color_shown = {0.5, 1, 0.7, 1},
	color_obscure = {0.5*0.6, 1*0.6, 0.7*0.6, 0.6},
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			zoom = 3,
			sqrt_percent = 45,
			noise = "fbm_perlin",
			floor = "CLOUD",
			wall = "OUTERSPACE",
			up = "CLOUD",
			down = "CLOUD",
			door = "CLOUD",
		},
	},
	post_process = function(level)
		game.state:makeWeather(level, 6, {max_nb=2, chance=1, dir=120, r=0.8, g=0.4, b=0.8, speed={0.1, 0.9}, alpha={0.2, 0.4}, particle_name="weather/grey_cloud_%02d"})
	end,
	foreground = function(level, dx, dx, nb_keyframes)
		local tick = core.game.getTime()
		local sr, sg, sb
		sr = 4 + math.sin(tick / 2000) / 2
		sg = 3 + math.sin(tick / 2700)
		sb = 3 + math.sin(tick / 3200)
		local max = math.max(sr, sg, sb)
		sr = sr / max
		sg = sg / max
		sb = sb / max

		level.map:setShown(sr, sg, sb, 1)
		level.map:setObscure(sr * 0.6, sg * 0.6, sb * 0.6, 1)
	end,
}
