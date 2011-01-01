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
	name = "Lost Dwarven Kingdom of Reknor",
	level_range = {18, 35},
	level_scheme = "player",
	max_level = 4,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 70, height = 70,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	ambient_music = "a_lomos_del_dragon_blanco.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.TileSet",
			tileset = {"7x7/base", "7x7/tunnel",},
			['.'] = "FLOOR",
			['#'] = "WALL",
			['+'] = "DOOR",
			["'"] = "DOOR",
			up = "UP",
			down = "DOWN",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {50, 60},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {12, 16},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {20, 30},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS",
			}, },
		},
		[4] = {
			decay = false,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/reknor-last",
				},
				actor = { nb_npc = {3, 3}, },
				object = { nb_object = {8, 10}, },
				trap = { nb_trap = {3, 3}, },
			},
		},
	},
	post_process = function(level)
		if level.level == 1 then
			local l = game.zone:makeEntityByName(level, "terrain", "IRON_THRONE_EDICT")
			if not l then return end
			for i = -1, 1 do for j = -1, 1 do
				local x, y = level.default_up.x + i, level.default_up.y + j
				if game.level.map:isBound(x, y) and (i ~= 0 or j ~= 0) and not game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") then
					game.zone:addEntity(level, l, "terrain", x, y)
					return
				end
			end end
		end
	end,
}
