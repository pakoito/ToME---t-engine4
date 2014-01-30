-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	name = "Dark ruins",
	level_range = {1, 1},
	max_level = 20,
	level_adjust_level = function(zone, level) return zone.base_level + zone.max_level - level.level end,
	width = 80, height = 23,
	persistent = "zone",
--	all_remembered = true,
	color_shown = {1, 1, 1, 1},
	color_obscure = {1*0.4, 1*0.4, 1*0.4, 1},
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			zoom = 6,
			sqrt_percent = 40,
			floor = "FLOOR",
			wall = "WALL",
			up = "UP",
			down = "DOWN",
		},
		actor = {
			class = "engine.generator.actor.Random",
		},
	},
	levels =
	{
		[20] = {generator={actor={ nb_npc = {2, 2}, down = "DOWN", force_last_stair = true }}},
		[19] = {generator={actor={ nb_npc = {3, 6} }}},
		[18] = {generator={actor={ nb_npc = {3, 6} }}},
		[17] = {generator={actor={ nb_npc = {3, 6} }}},
		[16] = {generator={actor={ nb_npc = {7, 10} }}},
		[15] = {generator={actor={ nb_npc = {7, 10} }}},
		[14] = {generator={actor={ nb_npc = {7, 10} }}},
		[13] = {generator={actor={ nb_npc = {7, 10} }}},
		[12] = {generator={actor={ nb_npc = {7, 10} }}},
		[11] = {generator={actor={ nb_npc = {7, 10} }}},
		[10] = {generator={actor={ nb_npc = {7, 10} }}},
		[9]  = {generator={actor={ nb_npc = {7, 10} }}},
		[8]  = {generator={actor={ nb_npc = {7, 10} }}},
		[7]  = {generator={actor={ nb_npc = {7, 10} }}},
		[6]  = {generator={actor={ nb_npc = {7, 10} }}},
		[5]  = {generator={actor={ nb_npc = {7, 14} }}},
		[4]  = {generator={actor={ nb_npc = {7, 14} }}},
		[3]  = {generator={actor={ nb_npc = {7, 14} }}},
		[2]  = {generator={actor={ nb_npc = {7, 14} }}},
		[1]  = {generator={actor={ nb_npc = {7, 14} }}},
	},
}
