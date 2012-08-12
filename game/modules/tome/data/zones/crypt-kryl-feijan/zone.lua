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
	name = "Dark crypt",
	level_range = {25,35},
	level_scheme = "player",
	max_level = 5,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 30, height = 30,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	color_shown = {0.6, 0.6, 0.6, 1},
	color_obscure = {0.6*0.6, 0.6*0.6, 0.6*0.6, 0.6},
	ambient_music = "Challenge.ogg",
	min_material_level = 2,
	max_material_level = 4,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 5,
			rooms = {"random_room", {"money_vault",5}},
			lite_room_chance = 20,
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 20},
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
		for uid, e in pairs(level.entities) do e.faction = e.hard_faction or "fearscape" end
	end,
	on_enter = function(lev)
		if lev < 4 then
			require("engine.ui.Dialog"):simplePopup("Crypt", "You hear an eerie chanting echoing from a distance.")
		elseif lev == 4 then
			require("engine.ui.Dialog"):simplePopup("Crypt", "The chanting grows louder. You hear a sudden high-pitched scream.")
		elseif lev == 5 then
			game.level.turn_counter = 20 * 10
			game.level.max_turn_counter = 20 * 10
			game.level.turn_counter_desc = "The cultists are about to sacrifice the woman. Stop them!"
			game.player:grantQuest("kryl-feijan-escape")
			game.player:learnLore("kryl-feijan-altar")
		end
	end,
	on_turn = function(self)
		if game.level.turn_counter then
			game.level.turn_counter = game.level.turn_counter - 1
			game.player.changed = true
			if game.level.turn_counter < 0 then
				game.level.turn_counter = nil
				require("engine.ui.Dialog"):simpleLongPopup("Crypt", "The woman lets out a sudden ear-splitting scream that turns from pain to horror as her stomach is ripped open from within by long dark claws. A towering black demon arises, rending her flesh to shreds, and replacing her dying scream with a terrifying roar.", 400)
				for uid, e in pairs(game.level.entities) do
					if e.define_as and e.define_as == "MELINDA" then
						local x, y = e.x, e.y
						e:die()
						local m = game.zone:makeEntityByName(game.level, "actor", "KRYL_FEIJAN")
						game.zone:addEntity(game.level, m, "actor", x, y)
						game.level.map:particleEmitter(x, y, 1, "blood")
						game.player:setQuestStatus("kryl-feijan-escape", engine.Quest.FAILED)

						local spot = game.level:pickSpot{type="locked-door", subtype="locked-door"}
						local g = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
						game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
						break
					end
				end
			end
		end
	end,
	on_leave = function(lev, old_lev, newzone)
		if not newzone then return end

		local melinda
		for uid, e in pairs(game.level.entities) do if e.define_as and e.define_as == "MELINDA" then melinda = e end end
		if melinda and not melinda.dead and core.fov.distance(game.player.x, game.player.y, melinda.x, melinda.y) > 1 then
			require("engine.ui.Dialog"):simplePopup("Crypt", "You can not abandon Melinda here!")
			return nil, nil, true
		end

		local g = game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN)
		if melinda and not melinda.dead and not game.player:isQuestStatus("kryl-feijan-escape", engine.Quest.FAILED) and g and g.change_level then
			game.player:setQuestStatus("kryl-feijan-escape", engine.Quest.DONE)
			world:gainAchievement("MELINDA_SAVED", game.player)
		end
	end,

	levels =
	{
		[1] = {
			generator = { map = {
				up = "FLOOR",
			}, },
		},
		[5] = {
			width = 90,
			height = 40,
			no_level_connectivity = true,
			no_worldport = true,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/crypt-kryl-feijan-last",
				},
				actor = {
					area = {x1=25, x2=85, y1=0, y2=49},
					nb_npc = {25, 25},
				},
				object = { nb_object = {0, 0}, },
				trap = { nb_trap = {0, 0}, },
			},
		},
	},
}

