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
	name = "Ambush!",
	level_range = {20, 50},
	level_scheme = "player",
	max_level = 1,
	actor_adjust_level = function(zone, level, e) return zone.base_level + 20 end,
	width = 50, height = 50,
	no_worldport = true,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
--	persistent = true,
	ambient_music = "Hold the Line.ogg",
	min_material_level = 3,
	max_material_level = 5,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/dreadfell-ambush",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {0, 0},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},

	on_enter = function(lev, old_lev, newzone)
		if newzone and game.player:hasQuest("staff-absorption") then
			game.player:hasQuest("staff-absorption"):start_ambush(game.player)
		end
	end,
}
