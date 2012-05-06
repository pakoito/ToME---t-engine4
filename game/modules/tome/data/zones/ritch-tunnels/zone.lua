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
	name = "Ritches Tunnels",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
--	all_lited = true,
	ambient_music = "Bazaar of Tal-Mashad.ogg",
	persistent = "zone",
	max_material_level = 2,
	no_random_lore = true,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			edge_entrances = {4,6},
			rooms = {"forest_clearing"},
			lite_room_chance = 90,
			rooms_config = {forest_clearing={pit_chance=5, filters={{type="insect", subtype="ritch", max_ood=2}}}},
			['.'] = "UNDERGROUND_SAND",
			['#'] = "SANDWALL_STABLE",
			up = "SAND_LADDER_UP",
			down = "SAND_LADDER_DOWN",
			door = "UNDERGROUND_SAND",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			filters = { {max_ood=2}, },
			guardian = "HIVE_MOTHER",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_object = {0, 0},
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
}
