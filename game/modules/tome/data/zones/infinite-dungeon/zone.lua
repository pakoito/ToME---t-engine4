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
	name = "Infinite Dungeon",
	level_range = {1, 1},
	level_scheme = "player",
	max_level = 1000000000,
	actor_adjust_level = function(zone, level, e) return math.floor((zone.base_level + level.level-1) * 1.2) + e:getRankLevelAdjust() + rng.range(-1,2) end,
	width = 70, height = 70,
--	all_remembered = true,
--	all_lited = true,
	no_worldport = true,
	infinite_dungeon = true,
	events_by_level = true,
	ambient_music = "Swashing the buck.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 14,
			rooms = {"random_room", {"pit",3}, {"greater_vault",7}},
			rooms_config = {pit={filters={}}},
			lite_room_chance = 50,
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "FLOOR",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.RandomStairGuard",
			guard_test = function(level)
				local allow = {[5]=true, [8]=true, [11]=true, [14]=true, [16]=true, [18]=true, [20]=true, [22]=true, [24]=true, [26]=true, [28]=true }
				if level.level >= 30 then return true end
				return allow[level.level]
			end,
			guard = {
				{random_boss={rank = 3.5, loot_quantity = 3,}},
			},
			nb_npc = {29, 39},
			filters = { {max_ood=6}, },
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
	post_process = function(level)
		-- Everything hates you in the infinite dungeon!
		for uid, e in pairs(level.entities) do e.faction = e.hard_faction or "enemies" end

		-- Some lore
		if level.level == 1 or level.level == 10 or level.level == 20 or level.level == 30 or level.level == 40 then
			local l = game.zone:makeEntityByName(level, "terrain", "ID_HISTORY"..level.level)
			if not l then return end
			for _, coord in pairs(util.adjacentCoords(level.default_up.x, level.default_up.y)) do
				if game.level.map:isBound(coord[1], coord[2]) and (i ~= 0 or j ~= 0) and not game.level.map:checkEntity(coord[1], coord[2], engine.Map.TERRAIN, "block_move") then
					game.zone:addEntity(level, l, "terrain", coord[1], coord[2])
					return
				end
			end
		end

		-- Provide some achievements
		if level.level == 10 then world:gainAchievement("INFINITE_X10", game.player)
		elseif level.level == 20 then world:gainAchievement("INFINITE_X20", game.player)
		elseif level.level == 30 then world:gainAchievement("INFINITE_X30", game.player)
		elseif level.level == 40 then world:gainAchievement("INFINITE_X40", game.player)
		elseif level.level == 50 then world:gainAchievement("INFINITE_X50", game.player)
		elseif level.level == 60 then world:gainAchievement("INFINITE_X60", game.player)
		elseif level.level == 70 then world:gainAchievement("INFINITE_X70", game.player)
		elseif level.level == 80 then world:gainAchievement("INFINITE_X80", game.player)
		elseif level.level == 90 then world:gainAchievement("INFINITE_X90", game.player)
		elseif level.level == 100 then world:gainAchievement("INFINITE_X100", game.player)
		elseif level.level == 150 then world:gainAchievement("INFINITE_X150", game.player)
		elseif level.level == 200 then world:gainAchievement("INFINITE_X200", game.player)
		elseif level.level == 300 then world:gainAchievement("INFINITE_X300", game.player)
		elseif level.level == 400 then world:gainAchievement("INFINITE_X400", game.player)
		elseif level.level == 500 then world:gainAchievement("INFINITE_X500", game.player)
		end
	end,
}
