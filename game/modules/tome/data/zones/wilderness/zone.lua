-- ToME - Tales of Maj'Eyal
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
	name = "Maj'Eyal",
	level_range = {1, 1},
	max_level = 1,
	width = 200, height = 130,
--	all_remembered = true,
--	all_lited = true,
	persistant = "memory",
	ambiant_music = "Remembrance.ogg",
	wilderness = true,
	wilderness_see_radius = 4,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "wilderness/maj-eyal",
		},
	}
}
