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
	name = "Small lumberjack village",
	level_range = {8, 14},
	max_level = 1,
	width = 25, height = 25,
	decay = {300, 800},
	persistant = "zone",
--	all_remembered = true,
	all_lited = true,
	persistant = "zone",
	ambiant_music = "Virtue lost.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "towns/lumberjack-village",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 20},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},
	on_enter = function(lev, old_lev, zone)
		if not game.level.heard_screams then
			require("engine.ui.Dialog"):simplePopup("Screams", "You hear screaming not too far from you.")
			game.level.heard_screams = true
		end
	end,
}
