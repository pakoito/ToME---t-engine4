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
	name = "Noxious Caldera",
	display_name = function(x, y) return "Dogroth Caldera" end,
	variable_zone_name = true,
	level_range = {25, 35},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	persistent = "zone",
	width = 70, height = 70,
	all_lited = true,
	day_night = true,
	color_shown = {0.9, 0.7, 0.4, 1},
	color_obscure = {0.9*0.6, 0.7*0.6, 0.4*0.6, 0.6},
	ambient_music = {"Mystery.ogg", "weather/jungle_base.ogg"},
	min_material_level = 3,
	max_material_level = 3,
	generator =  {
		map = {
			class = "mod.class.generator.map.Caldera",
			mountain = "MOUNTAIN_WALL",
			tree = "JUNGLE_TREE",
			grass = "JUNGLE_GRASS",
			water = "POISON_DEEP_WATER",
			up = "JUNGLE_GRASS_UP_WILDERNESS",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {40, 40},
			guardian = "",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
			filters = { {type="gem"} }
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {9, 15},
		},
	},

	post_process = function(level)
		game.state:makeWeatherShader(level, "weather_vapours", {move_factor=80000, evolve_factor=20000, color={1, 0.5, 0, 0.5}, zoom=3})

		game.state:makeAmbientSounds(level, {
			wind={ chance=1200, volume_mod=1.9, pitch=2, random_pos={rad=10}, files={"ambient/forest/wind1","ambient/forest/wind2","ambient/forest/wind3","ambient/forest/wind4"}},
			jungle1={ chance=250, volume_mod=0.6, pitch=0.6, random_pos={rad=10}, files={"ambient/jungle/jungle1","ambient/jungle/jungle2","ambient/jungle/jungle3"}},
			jungle2={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/jungle/jungle1","ambient/jungle/jungle2","ambient/jungle/jungle3"}},
			jungle3={ chance=250, volume_mod=1.6, pitch=1.4, random_pos={rad=10}, files={"ambient/jungle/jungle1","ambient/jungle/jungle2","ambient/jungle/jungle3"}},
		})
	end,

	fumes_active = true,

	on_enter = function()
		if not game.level.data.fumes_active or game.player:attr("no_breath") then return end
		if game.level.turn_counter then return end

		game.level.turn_counter = 60 * 10
		game.level.max_turn_counter = 60 * 10
		game.level.turn_counter_desc = "The noxious fumes of the caldera are slowly affecting you..."
	end,

	on_turn = function(self)
		if not game.level.turn_counter then return end

		game.level.turn_counter = game.level.turn_counter - 1
		game.player.changed = true
		if game.level.turn_counter < 0 then
			game.level.turn_counter = nil
			game.level.max_turn_counter = nil

			local dream = rng.range(1, 1)
			game:changeLevel(dream, "dreams")
		end
	end,
}
