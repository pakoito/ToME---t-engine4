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
	name = "Sandworm lair",
	level_range = {7, 16},
	level_scheme = "player",
	max_level = 4,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	no_level_connectivity = true,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	no_autoexplore = true,
	ambient_music = "Suspicion.ogg",
	min_material_level = function() return game.state:isAdvanced() and 3 or 2 end,
	max_material_level = function() return game.state:isAdvanced() and 4 or 3 end,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			no_tunnels = true,
			nb_rooms = 10,
			lite_room_chance = 0,
			rooms = {"forest_clearing"},
			['.'] = "UNDERGROUND_SAND",
			['#'] = "SANDWALL",
			up = "SAND_LADDER_UP",
			down = "SAND_LADDER_DOWN",
			door = "UNDERGROUND_SAND",
		},
		actor = {
			class = "mod.class.generator.actor.Sandworm",
			nb_npc = {20, 30},
			guardian = "SANDWORM_QUEEN",
			guardian_no_connectivity = true,
			-- Number of tunnelers + 2 (one per stair)
			nb_tunnelers = 7,
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
			filters = { {} }
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {9, 15},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "SAND_LADDER_UP_WILDERNESS",
			}, },
		},
	},

	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObject("NOTE"..level.level)
	end,
}
