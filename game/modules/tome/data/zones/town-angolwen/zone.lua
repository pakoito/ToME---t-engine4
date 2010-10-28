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
	name = "Angolwen",
	level_range = {20, 20},
	max_level = 1,
	width = 90, height = 90,
	persistant = "zone",
--	all_remembered = true,
	all_lited = true,
	persistant = "zone",
	ambiant_music = "Dreaming of Flying.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "towns/angolwen",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {0, 0},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},
	on_enter = function(lev, old_lev, zone)
		-- Update the stairs
		local spot = game.level:pickSpot{type="portal", subtype="back"}
		if spot then game.level.map(spot.x, spot.y, engine.Map.TERRAIN).change_zone = game.player.last_wilderness end
	end,
}
