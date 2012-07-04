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
	name = "Tempest Peak",
	level_range = {15, 22},
	level_scheme = "player",
	max_level = 2,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 70, height = 70,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	ambient_music = "Driving the Top Down.ogg",
	min_material_level = 2,
	max_material_level = 3,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 14,
			rooms = {"random_room", {"money_vault",5}, {"lesser_vault",8}},
			lesser_vaults_list = {"circle"},
			lite_room_chance = 100,
			['.'] = "ROCKY_GROUND",
			['#'] = "MOUNTAIN_WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {40, 50},
			guardian = "URKIS",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				class = "engine.generator.map.Static",
				map = "zones/tempest-peak-top",
			}, actor = {
				nb_npc = {0, 0},
			}, trap = {
				nb_trap = {0, 0},
			}, object = {
				nb_object = {0, 0},
			}, },
			color_shown = {0.3, 0.3, 0.3, 1},
			color_obscure = {0.3*0.6, 0.3*0.6, 0.3*0.6, 0.6},
			all_remembered = true,
			no_level_connectivity = true,
			background = function(level)
				local Map = require "engine.Map"
				if rng.chance(12) then
					local x1, y1 = rng.range(4, level.map.w - 5), rng.range(4, level.map.h - 5)
					local x2, y2 = x1 + rng.range(-4, 4), y1 + rng.range(5, 10)
					level.map:particleEmitter(x1, y1, math.max(math.abs(x2-x1), math.abs(y2-y1)), "lightning", {tx=x2-x1, ty=y2-y1})
					game:playSoundNear({x=x1,y=y1}, "talents/thunderstorm")
				end
			end
		},
	},

	on_enter = function(lev, old_lev, newzone)
		if lev == 1 and not game.level.created_way_back and game.player:isQuestStatus("lightning-overload", engine.Quest.COMPLETED, "tempest-entrance") then
			game.level.created_way_back = true
			local g = game.zone:makeEntityByName(game.level, "terrain", "ROCKY_UP_WILDERNESS")
			g.change_level_check = function() game.turn = game.turn + 5 * game.calendar.HOUR end -- Make it take time to travel
			game.zone:addEntity(game.level, g, "terrain", game.player.x, game.player.y)
		end
	end,
}
