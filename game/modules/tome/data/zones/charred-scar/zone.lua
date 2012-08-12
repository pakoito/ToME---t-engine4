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
	name = "Charred Scar",
	level_range = {30, 50},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 12, height = 500,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	no_level_connectivity = true,
	no_worldport = true,
	no_teleport_south = true,
	ambient_music = "Hold the Line.ogg",
	min_material_level = 4,
	max_material_level = 5,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/charred-scar",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			area = {x1=0, x2=11, y1=30, y2=410},
			nb_npc = {30, 30},
			rate = 0.25,
			max_attackers = 12,
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_trap = {0, 0},
		},
	},

	post_process = function(level)
		level.turn_counter = 600 * 10
		level.max_turn_counter = 600 * 10
		level.turn_counter_desc = "Hurry down south while the sun-paladins are holding off the orcs. Make their sacrifice worth it!"
	end,

	on_enter = function(lev, old_lev, newzone)
		if newzone then
			game.player:grantQuest("charred-scar")
		end
	end,

	on_turn = function(self)
		require("mod.class.generator.actor.CharredScar").new(self, game.level.map, game.level, {}):tick()
		game.level.turn_counter = game.level.turn_counter - 1
		game.player.changed = true
		if game.level.turn_counter < 0 then
			game.player:hasQuest("charred-scar"):setStatus(engine.Quest.COMPLETED, "not-stopped")
			game.player:hasQuest("charred-scar"):start_fyrk()
		end
	end,
}
