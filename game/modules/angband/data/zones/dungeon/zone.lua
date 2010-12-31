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
	name = "Angband",
	level_range = {1, 1},
	max_level = 127,
--	all_remembered = true,
--	all_lited = true,
	width = 98, height = 66,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 15,
			rooms = {"simple", "pilar"},
			lite_room_chance = 100,
			['.'] = "OPEN_FLOOR",
			['#'] = "GRANITE_WALL",
			up = "UP_STAIRCASE",
			down = "DOWN_STAIRCASE",
			door = "DOOR",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {30, 40},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {15, 18},
		},
	},
	levels =
	{
	},
}
