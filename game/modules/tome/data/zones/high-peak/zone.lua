-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
	name = "Taragoël, the High Peak",
	level_range = {55, 80},
	level_scheme = "player",
	max_level = 15,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 75,
	all_remembered = true,
	all_lited = true,
	persistant = "zone",
	no_worldport = true,
	ambiant_music = "Through the Dark Portal.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"simple", "pilar", {"pit",6}},
			rooms_config = {pit={filters={{type="orc"}, {type="naga"}, {type="dragon"}, {type="demon"}}}},
			lite_room_chance = 10,
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "FLOOR",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 30},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {15, 20},
		},
	},
	post_process = function(level)
		for uid, e in pairs(level.entities) do e.faction="blue-wizards" end
	end,
	levels =
	{
		[15] = {
			generator = {
			map = {
				class = "engine.generator.map.Static",
				map = "zones/high-peak-last",
			},
			actor = {
				nb_npc = {30, 40},
				area = {x1=0, x2=49, y1=23, y2=23+50},
			},
			},
		},
	},
}
