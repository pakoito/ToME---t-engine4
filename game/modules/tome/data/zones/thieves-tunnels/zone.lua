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
	name = "Unknown tunnels",
	level_range = {8, 18},
	level_scheme = "player",
	max_level = 2,
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 30, height = 30,
	ambient_music = "Zangarang.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.TileSet",
			tileset = {"3x3/base", "3x3/tunnel", "3x3/windy_tunnel"},
			tunnel_chance = 100,
			['.'] = "OLD_FLOOR",
			['#'] = "OLD_WALL",
			['+'] = "DOOR",
			["'"] = "DOOR",
			up = "OLD_FLOOR",
			down = "DOWN",
		},
		actor = { class = "mod.class.generator.actor.Random",nb_npc = {5, 7}, },
		trap = { class = "engine.generator.trap.Random", nb_trap = {3, 3}, },
	},
	levels = { [2] = {
		all_lited=true, all_remembered=true,
		generator = {
			map = { class = "engine.generator.map.Static", map = "quests/lost-merchant",},
			actor = { nb_npc = {0, 0} },
		},
		post_process = function(level)
			for uid, e in pairs(level.entities) do
				if e.faction ~= "victim" then
					e.faction="assassin-lair"
					e.cant_be_moved = true
				end
			end
		end,
	}, },

	on_leave = function(lev, old_lev, newzone)
		if not newzone then return end
		game.player:grantQuest("lost-merchant")
		game.player:hasQuest("lost-merchant"):leave_zone(game.player)
	end,
}
