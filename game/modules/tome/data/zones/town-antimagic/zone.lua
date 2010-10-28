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
	name = "Ziguranth training camp",
	level_range = {15, 30},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	max_level = 1,
	width = 25, height = 25,
	persistant = "zone",
	no_worldport = true,
	all_remembered = true,
	all_lited = true,
	ambiant_music = "Straight Into Ambush.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "towns/antimagic",
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
	on_enter = function(_, _, newzone)
		local q = game.player:hasQuest("antimagic")
		if q:isStatus(q.PENDING) then q:start_event() end
	end
}
