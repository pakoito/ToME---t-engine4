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
	name = "Lake of Nur",
	level_range = {15, 25},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	color_shown = {0.7, 0.7, 0.7, 1},
	color_obscure = {0.7*0.6, 0.7*0.6, 0.7*0.6, 0.6},
	ambient_music = "Woods of Eremae.ogg",
	min_material_level = 2,
	max_material_level = 3,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"random_room"},
			lite_room_chance = 0,
			['.'] = {"WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR_BUBBLE"},
			['#'] = "WATER_WALL",
			up = "WATER_UP",
			down = "WATER_DOWN",
			door = "WATER_DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 25},
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
			all_lited = true,
			day_night = true,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/lake-nur",
				},
				actor = {
					nb_npc = {0, 0},
				},
				object = {
					nb_object = {0, 0},
				},
				trap = {
					nb_trap = {0, 0},
				},
			},
		},
		[2] = {
			generator = {
				actor = {
					filters = {{special_rarity="water_rarity"}},
				},
			},
		},
		[3] = {
			generator = {
				map = {
					['.'] = "FLOOR",
					['#'] = "WALL",
					up = "UP",
					door = "DOOR",
					down = "SHERTUL_FORTRESS",
					force_last_stair = true,
				},
			},
		},
	},
	post_process = function(level)
		if level.level == 1 then
			game.state:makeWeather(level, 6, {max_nb=3, chance=1, dir=110, speed={0.1, 0.6}, alpha={0.4, 0.6}, particle_name="weather/dark_cloud_%02d"})
		end

		if level.level == 3 then
			game.state:makeAmbientSounds(level, {
				horror={ chance=400, volume_mod=1.5, files={"ambient/horror/ambient_horror_sound_01","ambient/horror/ambient_horror_sound_02","ambient/horror/ambient_horror_sound_03","ambient/horror/ambient_horror_sound_04","ambient/horror/ambient_horror_sound_05","ambient/horror/ambient_horror_sound_06"}},
			})
		end
	end,

	on_enter = function(lev, old_lev, newzone)
		local Dialog = require("engine.ui.Dialog")
		if lev == 2 and not game.level.shown_warning then
			Dialog:simplePopup("Lake of Nur", "You descend into the submerged ruins. The walls look extremely ancient, yet you feel power within this place.")
			game.level.shown_warning = true
		elseif lev == 3 and not game.level.shown_warning then
			Dialog:simplePopup("Lake of Nur", "As you descend to the next level you traverse a kind of magical barrier keeping the water away. You hear terrible screams.")
			game.level.shown_warning = true
		end
	end,
}
