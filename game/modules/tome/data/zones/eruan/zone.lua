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
	name = "Erúan",
	level_range = {30, 45},
	level_scheme = "player",
	max_level = 4,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = {"Bazaar of Tal-Mashad.ogg", "weather/desert_base.ogg"},
	min_material_level = 4,
	max_material_level = 4,
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			edge_entrances = {8,2},
			zoom = 6,
			sqrt_percent = 40,
			noise = "fbm_perlin",
			floor = "SAND",
			wall = "PALMTREE",
			up = "SAND_UP8",
			down = "SAND_DOWN2",
			do_ponds =  {
				nb = {0, 2},
				size = {w=25, h=25},
				pond = {{0.6, "DEEP_OCEAN_WATER"}, {0.8, "DEEP_OCEAN_WATER"}},
			},

			nb_rooms = {0,0,0,0,1},
			rooms = {"greater_vault"},
			greater_vaults_list = {"dragon_lair", "lava_island", "bandit-fortress", "horror-chamber"},
			lite_room_chance = 100,
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
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
				up = "SAND_UP_WILDERNESS",
			}, },
		},
		[4] = {
			generator = { map = {
				class = "engine.generator.map.Static",
				map = "zones/eruan-last",
			}, },
		},
	},

	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObject("NOTE"..level.level)

		-- Sand storms over Eruan
		game.state:makeWeather(level, 7, {max_nb=2, chance=1, dir=70, speed={24, 50}, alpha={0.2, 0.5}, particle_name="weather/sand_light_%02d"})

		game.state:makeAmbientSounds(level, {
			desert1={ chance=250, volume_mod=0.6, pitch=0.6, random_pos={rad=10}, files={"ambient/desert/desert1","ambient/desert/desert2","ambient/desert/desert3"}},
			desert2={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/desert/desert1","ambient/desert/desert2","ambient/desert/desert3"}},
			desert3={ chance=250, volume_mod=1.6, pitch=1.4, random_pos={rad=10}, files={"ambient/desert/desert1","ambient/desert/desert2","ambient/desert/desert3"}},
		})
	end,
}
