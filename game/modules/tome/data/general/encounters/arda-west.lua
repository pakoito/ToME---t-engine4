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

newEntity{
	name = "Novice mage",
	type = "harmless", subtype = "special", unique = true,
	level_range = {1, 10},
	rarity = 3,
	coords = {{ x=10, y=23, likelymap={
		[[    11111111   ]],
		[[ 1111111111111 ]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[ 1111111111111 ]],
		[[   111111111   ]],
	}}},
	-- Spawn the novice mage near the player
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = mod.class.NPC.new{
			name="Novice mage",
			type="humanoid", subtype="elf", faction="angolwen",
			display='@', color=colors.RED,
			can_talk = "mage-apprentice-quest",
		}
		g:resolve() g:resolve(nil, true)
		game.zone:addEntity(game.level, g, "actor", x, y)
		game.logPlayer(who, "#LIGHT_BLUE#You notice a novice mage nearby.")
		return true
	end,
}

newEntity{
	name = "Lost merchant",
	type = "hostile", subtype = "special", unique = true,
	level_range = {10, 20},
	rarity = 7,
	coords = {{ x=0, y=0, w=100, h=100}},
	on_encounter = function(self, who)
		who:runStop()
		engine.Dialog:yesnoPopup("Encounter", "You find an hidden trap door, and hear cries for help from within... Enter ?", function(ok)
			if not ok then
				game.logPlayer(who, "#LIGHT_BLUE#You carefully get away without making a sound.")
			else
				local zone = engine.Zone.new("ambush", {
					name = "Unknown tunnels",
					level_range = {8, 18},
					level_scheme = "player",
					max_level = 2,
					actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
					width = 20, height = 20,
					no_worldport = true,
					ambiant_music = "a_lomos_del_dragon_blanco.ogg",
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
						actor = { class = "engine.generator.actor.Random",nb_npc = {5, 7}, },
						trap = { class = "engine.generator.trap.Random", nb_trap = {3, 3}, },
					},
					npc_list = mod.class.NPC:loadList("/data/general/npcs/thieve.lua"),
					grid_list = mod.class.Grid:loadList("/data/general/grids/basic.lua"),
					object_list = mod.class.Object:loadList("/data/general/objects/objects.lua"),
					trap_list = mod.class.Trap:loadList("/data/general/traps/alarm.lua"),
					levels = { [2] = {
						all_lited=true, all_remembered=true,
						generator = {
							map = { class = "engine.generator.map.Static", map = "quests/lost-merchant",},
							actor = {
								nb_npc = {0, 0},
							},
						},
						post_process = function(level)
							for uid, e in pairs(level.entities) do if e.faction ~= "reunited-kingdom" then e.faction="assassin-lair" end end
						end,
					}, },

					on_leave = function(lev, old_lev, newzone)
						if not newzone then return end
						game.player:hasQuest("lost-merchant"):leave_zone(game.player)
					end,
				})
				game:changeLevel(1, zone)
				game.logPlayer(who, "#LIGHT_RED#You carefully open the trap door and enter the underground tunnels...")
				game.logPlayer(who, "#LIGHT_RED#As you enter you notice the trap door has no visible handle on the inside. You are stuck here!")
				who:grantQuest("lost-merchant")
			end
		end)
		return true
	end,
}

newEntity{
	name = "Ancient Elven Ruins",
	type = "harmless", subtype = "special", unique = true,
	level_range = {20, 30},
	rarity = 8,
	coords = {{ x=0, y=0, w=100, h=100}},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = mod.class.Grid.new{
			show_tooltip=true,
			name="Entrance to some ancient elven ruins",
			display='>', color={r=0, g=255, b=255},
			notice = true,
			change_level=1, change_zone="ancient-elven-ruins"
		}
		g:resolve() g:resolve(nil, true)
		game.zone:addEntity(game.level, g, "terrain", x, y)
		game.logPlayer(who, "#LIGHT_BLUE#You notice an entrance to what seems to be ancient elven ruins...")
		return true
	end,
}

newEntity{
	name = "Cursed Village",
	type = "harmless", subtype = "special", unique = true,
	level_range = {5, 15},
	rarity = 8,
	coords = {{ x=51, y=40, likelymap={
		[[    11111111   ]],
		[[ 1111111111111 ]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[111111111111111]],
		[[ 1111111111111 ]],
		[[   111111111   ]],
	}}},
	on_encounter = function(self, who)
		local Chat = require "engine.Chat"
		local chat = Chat.new("lumberjack-quest", {name="Half-dead lumberjack"}, who)
		chat:invoke()
		return true
	end,
}

---------------------------- Hostiles -----------------------------

-- Ambushed!
--[[
newEntity{
	name = "Bear ambush",
	type = "hostile", subtype = "ambush",
	level_range = {10, 50},
	rarity = 8,
	coords = {{ x=0, y=0, w=40, h=40}},
	on_encounter = function(self, who)
		local zone = engine.Zone.new("ambush", {
			name = "Ambush!",
			level_range = {1, 50},
			level_scheme = "player",
			max_level = 1,
			actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
			width = 20, height = 20,
			all_lited = true,
			ambiant_music = "last",
			generator =  {
				map = {
					class = "engine.generator.map.Heightmap",
					floor = "GRASS",
					up = "UP_WILDERNESS",
				},
				actor = { class = "engine.generator.actor.Random",nb_npc = {5, 7}, },
				trap = { class = "engine.generator.trap.Random", nb_trap = {0, 0}, },
			},

			npc_list = mod.class.NPC:loadList("/data/general/npcs/bear.lua"),
			grid_list = mod.class.Grid:loadList{"/data/general/grids/basic.lua", "/data/general/grids/forest.lua"},
			object_list = mod.class.Object:loadList("/data/general/objects/general.lua"),
			trap_list = {},
		})
		game:changeLevel(1, zone)
		engine.Dialog:simplePopup("Ambush!", "You have been ambushed by bears!")
		return true
	end,
}

newEntity{
	name = "bandits ambush",
	type = "hostile", subtype = "ambush",
	level_range = {5, 50},
	rarity = 8,
	coords = {{ x=0, y=0, w=40, h=40}},
	on_encounter = function(self, who)
		local zone = engine.Zone.new("ambush", {
			name = "Ambush!",
			level_range = {1, 50},
			level_scheme = "player",
			max_level = 1,
			actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
			width = 20, height = 20,
			all_lited = true,
			ambiant_music = "last",
			generator =  {
				map = {
					class = "engine.generator.map.Heightmap",
					floor = "GRASS",
					up = "UP_WILDERNESS",
				},
				actor = { class = "engine.generator.actor.Random",nb_npc = {5, 7}, },
				trap = { class = "engine.generator.trap.Random", nb_trap = {0, 0}, },
			},

			npc_list = mod.class.NPC:loadList("/data/general/npcs/thieve.lua"),
			grid_list = mod.class.Grid:loadList{"/data/general/grids/basic.lua", "/data/general/grids/forest.lua"},
			object_list = mod.class.Object:loadList("/data/general/objects/general.lua"),
			trap_list = {},
		})
		game:changeLevel(1, zone)
		engine.Dialog:simplePopup("Ambush!", "You have been ambushed by a party of bandits!")
		return true
	end,
}

newEntity{
	name = "Snake ambush",
	type = "hostile", subtype = "ambush",
	level_range = {3, 50},
	rarity = 5,
	coords = {{ x=0, y=0, w=40, h=40}},
	on_encounter = function(self, who)
		local zone = engine.Zone.new("ambush", {
			name = "Ambush!",
			level_range = {1, 50},
			level_scheme = "player",
			max_level = 1,
			actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
			width = 20, height = 20,
			all_lited = true,
			ambiant_music = "last",
			generator =  {
				map = {
					class = "engine.generator.map.Heightmap",
					floor = "GRASS",
					up = "UP_WILDERNESS",
				},
				actor = { class = "engine.generator.actor.Random",nb_npc = {5, 7}, },
				trap = { class = "engine.generator.trap.Random", nb_trap = {0, 0}, },
			},

			npc_list = mod.class.NPC:loadList("/data/general/npcs/snake.lua"),
			grid_list = mod.class.Grid:loadList{"/data/general/grids/basic.lua", "/data/general/grids/forest.lua"},
			object_list = mod.class.Object:loadList("/data/general/objects/general.lua"),
			trap_list = {},
		})
		game:changeLevel(1, zone)
		engine.Dialog:simplePopup("Ambush!", "You setp in a nest of snakes!")
		return true
	end,
}
newEntity{
	name = "Ant ambush",
	type = "hostile", subtype = "ambush",
	level_range = {3, 50},
	rarity = 5,
	coords = {{ x=0, y=0, w=40, h=40}},
	on_encounter = function(self, who)
		local zone = engine.Zone.new("ambush", {
			name = "Ambush!",
			level_range = {1, 50},
			level_scheme = "player",
			max_level = 1,
			actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
			width = 50, height = 50,
			all_lited = true,
			all_remembered = true,
			ambiant_music = "last",
			generator =  {
				map = {
					class = "engine.generator.map.GOL",
					floor = "GRASS",
					wall = "TREE",
					up = "UP_WILDERNESS",
				},
				actor = { class = "engine.generator.actor.Random",nb_npc = {5, 7}, },
				trap = { class = "engine.generator.trap.Random", nb_trap = {0, 0}, },
			},

			npc_list = mod.class.NPC:loadList("/data/general/npcs/ant.lua"),
			grid_list = mod.class.Grid:loadList{"/data/general/grids/basic.lua", "/data/general/grids/forest.lua"},
			object_list = mod.class.Object:loadList("/data/general/objects/general.lua"),
			trap_list = {},
		})
		game:changeLevel(1, zone)
		engine.Dialog:simplePopup("Ambush!", "You step in a nest of ants!")
		return true
	end,
}
]]
