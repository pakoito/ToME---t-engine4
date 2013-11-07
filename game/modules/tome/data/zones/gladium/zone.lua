-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	name = "Fortress Gladium",
	level_range = {1, 1},
	level_scheme = "player",
	max_level = 1,
	actor_adjust_level = function(zone, level, e) return zone.base_level end,
	width = 15, height = 15,
	all_remembered = true,
	all_lited = true,
	no_level_connectivity = true,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/gladium",
		},
	},
}
