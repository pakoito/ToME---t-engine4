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
	name = "Derth",
	level_range = {1, 1},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	max_level = 1,
	width = 196, height = 80,
	persistant = "zone",
	all_remembered = true,
	all_lited = true,
	ambiant_music = "Virtue lost.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "towns/derth",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {10, 10},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},

	on_enter = function(_, _, newzone)
		if game.player.level >= 12 and game.player.level <= 20 and not game.player:hasQuest("lightning-overload") then
			game.player:grantQuest("lightning-overload")
		elseif game.player:hasQuest("lightning-overload") then
			game.player:hasQuest("lightning-overload"):reenter_derth()
		end
	end
}
