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
	name = "Grushnak Pride",
	display_name = function()
		if game.level.level % 2 == 0 then return "Grushnak Pride ("..(game.level.level/2)..")"
		else return "Grushnak Pride (guarded barracks)"
		end
	end,
	variable_zone_name = true,
	level_range = {35, 60},
	level_scheme = "player",
	max_level = 6,
	decay = {300, 800},
	-- 10 levels but really only 5, the 5 others are just transitions
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + math.floor(level.level / 2) + rng.range(-1,2) end,
	level_adjust_level = function(zone, level) return zone.base_level + math.floor(level.level / 2) end,
	width = 50, height = 50,
	persistent = "zone",
--	all_remembered = true,
--	all_lited = true,
	ambient_music = "Thrall's Theme.ogg",
	min_material_level = 4,
	max_material_level = 5,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			pride = "grushnak",
			nb_rooms = 10,
			lite_room_chance = 20,
			rooms = {"forest_clearing", {"money_vault",5}, {"pit",7}, {"greater_vault",8}},
			rooms_config = {pit={filters={{subtype="orc"},{subtype="troll"}}}},
			['.'] = "UNDERGROUND_FLOOR",
			['#'] = {"UNDERGROUND_TREE","UNDERGROUND_TREE2","UNDERGROUND_TREE3","UNDERGROUND_TREE4","UNDERGROUND_TREE5","UNDERGROUND_TREE6","UNDERGROUND_TREE7","UNDERGROUND_TREE8","UNDERGROUND_TREE9","UNDERGROUND_TREE10","UNDERGROUND_TREE11","UNDERGROUND_TREE12","UNDERGROUND_TREE13","UNDERGROUND_TREE14","UNDERGROUND_TREE15","UNDERGROUND_TREE16","UNDERGROUND_TREE17","UNDERGROUND_TREE18","UNDERGROUND_TREE19","UNDERGROUND_TREE20",},
			up = "UNDERGROUND_LADDER_UP",
			down = "UNDERGROUND_LADDER_DOWN",
			door = "UNDERGROUND_FLOOR",
			['+'] = "UNDERGROUND_FLOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			guardian = "GRUSHNAK",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {3, 6},
		},
	},
	post_process = function(level)
		-- Place a lore note on each level
		if level.level >= 2 and level.level <= 6 then
			game:placeRandomLoreObject("GARKUL_HISTORY"..(level.level-1))
		end

		for uid, e in pairs(level.entities) do e.faction = e.hard_faction or "orc-pride" end
	end,
	levels =
	{
		[1] = { generator = {
			map = { class = "engine.generator.map.Static", map = "zones/prides-middle" },
			actor = { nb_npc = {0, 0} },
			object = { nb_object = {0, 0} },
		}},
		[3] = { generator = {
			map = { class = "engine.generator.map.Static", map = "zones/prides-middle" },
			actor = { nb_npc = {0, 0} },
			object = { nb_object = {0, 0} },
		}},
		[5] = { generator = {
			map = { class = "engine.generator.map.Static", map = "zones/prides-middle" },
			actor = { nb_npc = {0, 0} },
			object = { nb_object = {0, 0} },
		}},
		[6] = {
			generator = { map = {
				down = "SLIME_TUNNELS",
				force_last_stair = true,
			}, },
		},
	},
}
