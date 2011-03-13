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

newEntity{
	name = "Novice mage",
	type = "harmless", subtype = "special", unique = true,
	level_range = {1, 10},
	rarity = 1,
	on_world_encounter = "angolwen",
	-- Spawn the novice mage near the player
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = mod.class.WorldNPC.new{
			name="Novice mage",
			type="humanoid", subtype="elf", faction="angolwen",
			display='@', color=colors.RED,
			can_talk = "mage-apprentice-quest",
			unit_power = 300,
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
		engine.ui.Dialog:yesnoPopup("Encounter", "You find a hidden trap door, and hear cries for help from within...", function(ok)
			if not ok then
				game.logPlayer(who, "#LIGHT_BLUE#You carefully get away without making a sound.")
			else
				local zone = engine.Zone.new("ambush", {
					name = "Unknown tunnels",
					level_range = {8, 18},
					level_scheme = "player",
					max_level = 2,
					actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
					width = 30, height = 30,
					no_worldport = true,
					ambient_music = "a_lomos_del_dragon_blanco.ogg",
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
							for uid, e in pairs(level.entities) do
								if e.faction ~= "allied-kingdoms" then
									e.faction="assassin-lair"
									e.cant_be_moved = true
								end
							end
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
		end, "Enter the tunnels", "Leave carefully", true)
		return true
	end,
}

newEntity{
	name = "Sect of Kryl-Faijan",
	type = "hostile", subtype = "special", unique = true,
	level_range = {24, 35},
	rarity = 7,
	min_level = 24,
	coords = {{ x=0, y=0, w=100, h=100}},
	on_encounter = function(self, who)
		who:runStop()
		engine.ui.Dialog:yesnoLongPopup("Encounter", "You find an entrance to an old crypt. An aura of terrible evil emanates from this place, you feel threatened just standing there.\nYou hear the muffled cries of a woman coming from inside.", 400, function(ok)
			if not ok then
				game.logPlayer(who, "#LIGHT_BLUE#You carefully get away without making a sound.")
			else
				game:changeLevel(1, "crypt-kryl-feijan")
				game.logPlayer(who, "#LIGHT_RED#You carefully open the door and enter the underground crypt...")
				game.logPlayer(who, "#LIGHT_RED#As you enter you notice the door has no visible handle on the inside. You are stuck here!")
			end
		end, "Enter the crypt", "Leave carefully", true)
		return true
	end,
}

newEntity{
	name = "Ancient Elven Ruins",
	type = "harmless", subtype = "special", unique = true,
	level_range = {30, 40},
	rarity = 8,
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
	on_world_encounter = "lumberjack-cursed",
	on_encounter = function(self, who)
		local Chat = require "engine.Chat"
		local chat = Chat.new("lumberjack-quest", {name="Half-dead lumberjack"}, who)
		chat:invoke()
		return true
	end,
}

newEntity{
	name = "Ruined Dungeon",
	type = "harmless", subtype = "special", unique = true,
	level_range = {10, 30},
	rarity = 1,
	on_world_encounter = "infinite-dungeon",
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = mod.class.Grid.new{
			show_tooltip=true,
			name="Entrance to a ruined dungeon",
			display='>', color={r=255, g=0, b=0},
			notice = true,
			change_level=1, change_zone="ruined-dungeon"
		}
		g:resolve() g:resolve(nil, true)
		game.zone:addEntity(game.level, g, "terrain", x, y)
		game.logPlayer(who, "#LIGHT_BLUE#You notice an entrance to a ruined dungeon. The air around it feels stale.")
		return true
	end,
}

newEntity{
	name = "Mark of the Spellblaze",
	type = "harmless", subtype = "special", unique = true,
	level_range = {22, 33},
	rarity = 4,
	on_world_encounter = "mark-spellblaze",
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = mod.class.Grid.new{
			show_tooltip=true,
			name="Mark of the Spellblaze",
			display='>', color=colors.VIOLET,
			notice = true,
			change_level=1, change_zone="mark-spellblaze"
		}
		g:resolve() g:resolve(nil, true)
		game.zone:addEntity(game.level, g, "terrain", x, y)
		game.logPlayer(who, "#LIGHT_BLUE#You notice an area where the effects of the spellblaze seem to persist still.")
		return true
	end,
}
