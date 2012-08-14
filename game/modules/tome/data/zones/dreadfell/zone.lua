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
	name = "Dreadfell",
	level_range = {15, 26},
	level_scheme = "player",
	max_level = 9,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	ambient_music = {"Dark Secrets.ogg","weather/dungeon_base.ogg"},
	min_material_level = function() return game.state:isAdvanced() and 4 or 3 end,
	max_material_level = function() return game.state:isAdvanced() and 5 or 4 end,
	is_dreadfell = true,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"random_room", {"money_vault",5}, {"pit",7}, {"greater_vault",8}},
--			rooms = {"random_room", "greater_vault"},
--			greater_vaults_list = {"trickvault"},
			rooms_config = {pit={filters={{type="undead"}}}},
			lite_room_chance = 100,
			['+'] = "DOOR",
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			guardian = "THE_MASTER",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
			filters = { {ego_chance = 20} }
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
		},
	},
	post_process = function(level)
		for uid, e in pairs(level.entities) do e.faction = e.hard_faction or "dreadfell" end

		-- Put lore near the up stairs
		if game.zone.created_lore and game.zone.created_lore[level.level] then
			local post = game.zone:makeEntityByName(level, "terrain", "LORE_NOTE")
			post.lore = "dreadfell-note-"..game.zone.created_lore[level.level]

			local x, y = rng.range(0, level.map.w-1), rng.range(0, level.map.h-1)
			local tries = 0
			while (level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") or level.map:checkEntity(x, y, engine.Map.TERRAIN, "change_level") or (level.map.room_map[x][y] and level.map.room_map[x][y].special)) and tries < 100 do
				x, y = rng.range(0, level.map.w-1), rng.range(0, level.map.h-1)
				tries = tries + 1
			end
			if tries < 100 then
				game.zone:addEntity(level, post, "terrain", x, y)
			end
		end

		-- Put lore near the up stairs
		if level.level == 3 then
			local post = game.zone:makeEntityByName(level, "terrain", "LORE_NOTE")
			post.lore = "dreadfell-poem-master"

			local x, y = rng.range(0, level.map.w-1), rng.range(0, level.map.h-1)
			local tries = 0
			while (level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") or level.map:checkEntity(x, y, engine.Map.TERRAIN, "change_level") or (level.map.room_map[x][y] and level.map.room_map[x][y].special)) and tries < 100 do
				x, y = rng.range(0, level.map.w-1), rng.range(0, level.map.h-1)
				tries = tries + 1
			end
			if tries < 100 then
				game.zone:addEntity(level, post, "terrain", x, y)
			end
		end

		-- Put lore near the up stairs
		if level.level == 2 or level.level == 5 or level.level == 7 then
			game:placeRandomLoreObject("UNDEAD_POEM_LEVEL_"..level.level)
		end

		game.state:makeAmbientSounds(level, {
			dungeon2={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/dungeon/dungeon1","ambient/dungeon/dungeon2","ambient/dungeon/dungeon3","ambient/dungeon/dungeon4","ambient/dungeon/dungeon5"}},
		})
	end,
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS",
			}, },
		},
	},
	on_enter = function(_, _, newzone)
		if newzone and not game.zone.created_lore then
			local levels = {1,2,4,5,6,7,8}
			game.zone.created_lore = {}
			for i = 1, 5 do
				local lev = rng.tableRemove(levels)
				game.zone.created_lore[lev] = i
				print("Lore "..i.." on level "..lev)
			end
		end
	end,
	on_leave = function(lev, old_lev, newzone)
		if not newzone then return end
		-- Ambushed!
		if game.player:isQuestStatus("staff-absorption", engine.Quest.PENDING) and not game.player:isQuestStatus("staff-absorption", engine.Quest.COMPLETED, "ambush") then
			return 1, "dreadfell-ambush"
		end
	end,
}
