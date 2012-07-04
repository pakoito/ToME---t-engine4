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
	name = "Ring of Blood",
	display_name = function(x, y)
		if game.level.level < 3 then return "Slavers Compound ("..game.level.level..")" end
		return "Ring of Blood"
	end,
	variable_zone_name = true,
	level_range = {10, 25},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	persistent = "zone",
	ambient_music = "Sinestra.ogg",
	max_material_level = 2,
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			zoom = 5,
			sqrt_percent = 30,
			noise = "fbm_perlin",
			floor = "FLOOR",
			wall = "WALL",
			up = "UP",
			down = "DOWN",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {10, 15},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {3, 5},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
		},
	},
	levels = {
		[1] = {
			generator =  {
				map = {
					up = "UP_WILDERNESS",
				},
			},
		},
		[3] = {
			all_remembered = true,
			generator =  {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/ring-of-blood",
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
		},
	},
	post_process = function(level)
		-- Place spectators
		for i = 1, 30 do
			local e = game.zone:makeEntityByName(level, "actor", "SPECTATOR")
			local where = game.level:pickSpotRemove{type="npcs", subtype="spectators"}
			if e and where then game.zone:addEntity(level, e, "actor", where.x, where.y) end
		end
	end,
	on_enter = function(lev, old_lev, newzone)
		if newzone and not game.level.shown_warning then
			game.player:grantQuest("ring-of-blood")
			game.level.shown_warning = true
		end
	end,
	on_turn = function(self)
		if game.turn % 10 ~= 0 or not game.player:hasQuest("ring-of-blood") then return end
		game.player:hasQuest("ring-of-blood"):on_turn()
	end,
}
