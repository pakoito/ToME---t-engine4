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
	name = "Slazish Fens",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	no_worldport = true,
	persistent = "zone",
	color_shown = {0.7, 0.7, 0.7, 1},
	color_obscure = {0.7*0.6, 0.7*0.6, 0.7*0.6, 0.6},
	ambient_music = "Dark Secrets.ogg",
	min_material_level = function() return game.state:isAdvanced() and 3 or 1 end,
	max_material_level = function() return game.state:isAdvanced() and 4 or 2 end,
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			edge_entrances = {4,6},
			zoom = 7,
			sqrt_percent = 30,
			sqrt_percent2 = 25,
			noise = "fbm_perlin",
			floor2 = function() if rng.chance(20) then return "BOGWATER_MISC" else return "BOGWATER" end end,
			floor = function() if rng.chance(20) then return "FLOWER" else return "GRASS" end end,
			wall = "BOGTREE",
			up = "GRASS_UP4",
			down = "GRASS_DOWN6",

--			nb_rooms = {0,0,0,1},
--			rooms = {"lesser_vault"},
--			lesser_vaults_list = {"honey_glade", "forest-ruined-building1", "forest-ruined-building2", "forest-ruined-building3", "forest-snake-pit", "mage-hideout"},
--			lite_room_chance = 100,
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {7, 10},
			filters = { {max_ood=2}, },
			guardian = "ZOISLA",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "GRASS_UP_WILDERNESS",
			}, },
		},
		[3] = {
			generator = { map = {
				force_last_stair = true,
				down = "GRASS",
			}, },
		},
		-- Hidden treasure level
		[4] = {
			ambient_music = {"Rainy Day.ogg", "weather/rain.ogg"},
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/trollmire-treasure",
				},
				trap = { nb_trap = {0, 0} },
				object = { nb_object = {3, 4} },
				actor = { nb_npc = {2, 2} },
			},
		},
	},

	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObjectScale("NOTE", 5, level.level)

		-- Rain on bill
		if level.level == 4 and config.settings.tome.weather_effects then
			local Map = require "engine.Map"
			level.foreground_particle = require("engine.Particles").new("raindrops", 1, {width=Map.viewport.width, height=Map.viewport.height})
		end

		-- Some clouds floating happily over the trollmire
		game.state:makeWeather(level, 7, {max_nb=1, speed={0.5, 1.6}, shadow=true, alpha={0.23, 0.35}, particle_name="weather/grey_cloud_%02d"})
	end,

	foreground = function(level, x, y, nb_keyframes)
		if not config.settings.tome.weather_effects or not level.foreground_particle then return end
		level.foreground_particle.ps:toScreen(x, y, true, 1)
	end,

	on_enter = function(lev, old_lev, newzone)
		if lev == 3 and game.player:hasQuest("trollmire-treasure") then
			game.player:hasQuest("trollmire-treasure"):enter_level3()
		end
	end,
}
