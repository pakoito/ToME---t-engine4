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
	name = "Mount Doom",
	level_range = {30, 35},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 12, height = 500,
--	all_remembered = true,
	all_lited = true,
	persistant = "zone",
	no_level_connectivity = true,
	ambiant_music = "Hold the Line.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/mount-doom",
		},
		actor = {
			class = "engine.generator.actor.Random",
			area = {x1=0, x2=11, y1=30, y2=410},
			nb_npc = {30, 30},
			rate = 0.25,
			max_attackers = 12,
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
		},
	},

	post_process = function(level)
		level.turn_counter = 700 * 10
	end,

	on_enter = function(lev, old_lev, newzone)
		if newzone then
			game.player:grantQuest("mount-doom")
		end
	end,

	on_turn = function(self)
		require("mod.class.generator.actor.MountDoom").new(self, game.level.map, game.level, {}):tick()
		game.level.turn_counter = game.level.turn_counter - 1
		game.player.changed = true
		if game.level.turn_counter < 0 then
			game.player:hasQuest("mount-doom"):setStatus(engine.Quest.COMPLETED, "not-stopped")
			game.player:hasQuest("mount-doom"):start_fyrk()
		end
	end,
}
