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
	name = "Escape from Reknor",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
--	all_lited = true,
	no_worldport = true,
	persistent = "zone",
	ambient_music = "Enemy at the gates.ogg",
	max_material_level = 2,
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
			force_down = true,
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {50, 60},
			filters = { {max_ood=2}, },
			nb_spots = 2, on_spot_chance = 35,
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
			nb_spots = 2, on_spot_chance = 80,
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
				up = "FLOOR",
			}, },
		},
		[3] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/reknor-escape-last",
				},
				actor = {
					nb_npc = {0, 0},
				},
			},
		},
	},

	on_enter = function(lev, old_lev, new_zone)
		if lev == 2 then
			game.player:forceLevelup(2)
			local norgan = game.party:findMember{type="squadmate"}
			if norgan then norgan:forceLevelup(2) end
		end
		if lev == 3 then
			game.player:forceLevelup(3)
			local norgan = game.party:findMember{type="squadmate"}
			if norgan then norgan:forceLevelup(3) end
		end
	end,

	on_leave = function(lev, old_lev, newzone)
		if not newzone then return end

		local norgan = game.party:findMember{type="squadmate"}
		if norgan then game.player:setQuestStatus("start-dwarf", engine.Quest.COMPLETED, "norgan") end
		game.player:setQuestStatus("start-dwarf", engine.Quest.COMPLETED)
		if norgan and not norgan.dead then
			local chat = require("engine.Chat").new("norgan-saved", norgan, game.player)
			chat:invoke()
		end
		if norgan then game.party:removeMember(norgan, true) end
	end,
}
