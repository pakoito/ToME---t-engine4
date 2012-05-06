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
	name = "Vor Pride",
	level_range = {35, 60},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 64, height = 64,
	persistent = "zone",
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	ambient_music = "Breaking the siege.ogg",
	min_material_level = 4,
	max_material_level = 5,
	no_level_connectivity = true,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/prides",
			up = "FLAT_UP6",
			down = "FLAT_DOWN4",
			sublevel = {
				class = "engine.generator.map.Town",
				pride = "vor",
				building_chance = 70,
				max_building_w = 8, max_building_h = 8,
				edge_entrances = {6,4},
				floor = "FLOOR",
				external_floor = "FLOOR",
				wall = "WALL",
				door = "DOOR",
				up = "FLOOR",
				down = "FLOOR",

				nb_rooms = {0,0,0,1},
				rooms = {"lesser_vault"},
				lesser_vaults_list = {"orc-armoury", "double-t", "circle", "hostel", "orc-necromancer", "horror-chamber"},
				lite_room_chance = 100,
			},
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			guardian = "VOR",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {3, 6},
		},
	},
	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObjectScale("ORC_HISTORY", 5, level.level)

		for uid, e in pairs(level.entities) do e.faction = e.hard_faction or "orc-pride" end
	end,
	levels =
	{
		[1] = {
			generator = { map = {
				up = "FLAT_UP_WILDERNESS",
			}, },
		},
		[3] = {
			generator = { map = {
				down = "FLAT_UP_WILDERNESS",
			}, },
		},
	},
}
