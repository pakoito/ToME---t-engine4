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
	name = "Dreams",
	display_name = function(x, y)
		if game.level.level == 1 then return "Dream of vulnerability" end
		if game.level.level == 2 then return "Dream of loss" end
		return "Dream ???"
	end,
	variable_zone_name = true,
	level_range = {1, 1},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	ambient_music = "Woods of Eremae.ogg",
	min_material_level = 3,
	max_material_level = 3,
	generator =  {
	},
	levels =
	{
		[1] = {
			motionblur = 2,
			width = 48, height = 48,
			color_shown = {0.9, 0.7, 0.4, 1},
			color_obscure = {0.9*0.6, 0.7*0.6, 0.4*0.6, 0.6},
			generator = {
				map = {
					class = "engine.generator.map.Maze",
					up = "FLOOR",
					down = "DREAM_END",
					wall = "JUNGLE_TREE",
					floor = "JUNGLE_GRASS",
					widen_w = 3, widen_h = 3,
					force_last_stair = true,
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {20, 20},
					filters = {{type="feline"}},
					randelite = 0,
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
			post_process = function(level)
				-- Add mouse tunnels
				local Map = require "engine.Map"
				local dirs = {}
				for i = 1, level.map.w - 2 do for j = 1, level.map.h - 2 do
					while true do -- Breakable
						if level.map:checkEntity(i, j, Map.TERRAIN, "block_move") then break end

						local g4 = level.map:checkEntity(i - 1, j, Map.TERRAIN, "block_move")
						local g6 = level.map:checkEntity(i + 1, j, Map.TERRAIN, "block_move")
						local g8 = level.map:checkEntity(i, j - 1, Map.TERRAIN, "block_move")
						local g2 = level.map:checkEntity(i, j + 1, Map.TERRAIN, "block_move")

						if g4 then for z = i - 1, 1, -1 do
							if not level.map:checkEntity(z, j, Map.TERRAIN, "block_move") then
								dirs[#dirs+1] = {dir=4, x1=i-1, y1=j, x2=z+1, y2=j}
								break
							end
						end end
						if g6 then for z = i + 1, level.map.w - 2 do
							if not level.map:checkEntity(z, j, Map.TERRAIN, "block_move") then
								dirs[#dirs+1] = {dir=6, x1=i+1, y1=j, x2=z-1, y2=j}
								break
							end
						end end
						if g8 then for z = j - 1, 1, -1 do
							if not level.map:checkEntity(i, z, Map.TERRAIN, "block_move") then
								dirs[#dirs+1] = {dir=8, x1=i, y1=j-1, x2=i, y2=z+1}
								break
							end
						end end
						if g2 then for z = j + 1, level.map.h - 2 do
							if not level.map:checkEntity(i, z, Map.TERRAIN, "block_move") then
								dirs[#dirs+1] = {dir=2, x1=i, y1=j+1, x2=i, y2=z-1}
								break
							end
						end end

						break -- break the while
					end
				end end

				local nb = 0
				while nb < 15 and #dirs > 0 do
					local spot = rng.tableRemove(dirs)

					if not level.map:checkEntity(spot.x1, spot.y1, Map.TERRAIN, "mouse_hole") and not level.map:checkEntity(spot.x2, spot.y2, Map.TERRAIN, "mouse_hole") then
						local t1, t2
						if spot.dir == 4 then t1, t2 = {z=5, display_x=-1.5, display_w=2, image="terrain/road_going_left_01.png"}, {z=5, display_x=-0.5, display_w=2, image="terrain/road_going_right_01.png"}
						elseif spot.dir == 6 then t1, t2 = {z=5, display_x=-0.5, display_w=2, image="terrain/road_going_right_01.png"}, {z=5, display_x=-1.5, display_w=2, image="terrain/road_going_left_01.png"}
						elseif spot.dir == 8 then t1, t2 = {z=5, display_y=-1.5, display_h=2, image="terrain/road_upwards_01.png"}, {z=5, display_y=-0.5, display_h=2, image="terrain/road_downwards_01.png"}
						elseif spot.dir == 2 then t1, t2 = {z=5, display_y=-0.5, display_h=2, image="terrain/road_downwards_01.png"}, {z=5, display_y=-1.5, display_h=2, image="terrain/road_upwards_01.png"}
						end

						local g = game.zone.grid_list.DREAM_MOUSE_HOLE:clone()
						g.add_displays[#g.add_displays+1] = mod.class.Grid.new(t1)
						g.mouse_hole = {x=spot.x2, y=spot.y2}
						game.zone:addEntity(level, g, "terrain", spot.x1, spot.y1)

						local g = game.zone.grid_list.DREAM_MOUSE_HOLE:clone()
						g.add_displays[#g.add_displays+1] = mod.class.Grid.new(t2)
						g.mouse_hole = {x=spot.x1, y=spot.y1}
						game.zone:addEntity(level, g, "terrain", spot.x2, spot.y2)

						nb = nb + 1
					end
				end
			end,
		},
		[2] = {
			motionblur = 3,
			width = 50, height = 50,
			color_shown = {0.9, 0.7, 0.4, 1},
			color_obscure = {0.9*0.6, 0.7*0.6, 0.4*0.6, 0.6},
			generator = {
				map = {
					class = "engine.generator.map.Building",
					max_block_w = 15, max_block_h = 15,
					max_building_w = 5, max_building_h = 5,
					floor = function() if rng.chance(20) then return "DREAM_STONE" else return "BAMBOO_HUT_FLOOR" end end,
					external_floor = "BAMBOO_HUT_FLOOR",
					wall = "BAMBOO_HUT_WALL",
					up = "BAMBOO_HUT_FLOOR",
					down = "BAMBOO_HUT_FLOOR",
					door = "BAMBOO_HUT_DOOR",
					force_last_stair = true,
					lite_room_chance = 100,
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {25, 25},
					filters = {{name="yeek illusion"}},
					randelite = 0,
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
			post_process = function(level)
				local list = {}
				for uid, e in pairs(level.entities) do
					if e.subtype == "yeek" then list[#list+1] = e end
				end
				local wife = rng.table(list)
				wife.is_wife = true

				level.back_shader = require("engine.Shader").new("funky_bubbles", {})
			end,
			background = function(level, x, y, nb_keyframes)
				if not level.back_shader then return end
				local sx, sy = level.map._map:getScroll()
				local mapcoords = {(-sx + level.map.mx * level.map.tile_w) / level.map.viewport.width , (-sy + level.map.my * level.map.tile_h) / level.map.viewport.height}
				level.back_shader:setUniform("xy", mapcoords)
				level.back_shader.shad:use(true)
				core.display.drawQuad(x, y, level.map.viewport.width, level.map.viewport.height, 255, 255, 255, 255)
				level.back_shader.shad:use(false)
			end,
		},
	},

	on_enter = function(lev, old_lev)
		-- Dream of vulnerability
		if lev == 1 then
			local f = require("mod.class.Player").new{
				name = "frail mouse", image = "npc/vermin_rodent_giant_white_mouse.png",
				type = "vermin", subtype = "rodent",
				display = "r", color=colors.WHITE,
				body = { INVEN = 10 },
				infravision = 10,
				sound_moam = {"creatures/rats/rat_hurt_%d", 1, 2},
				sound_die = {"creatures/rats/rat_die_%d", 1, 2},
				sound_random = {"creatures/rats/rat_%d", 1, 3},
				stats = { str=8, dex=15, mag=3, con=5, cun=15, },
				combat = {sound="creatures/rats/rat_attack", dam=5, atk=0, apr=10 },
				combat_armor = 1, combat_def = 1,
				rank = 1,
				movement_speed = 1.4,
				size_category = 1,
				level_range = {1, 1}, exp_worth = 1,
				max_life = 10,
				mouse_turn = game.turn,
				resolvers.talents{
					T_STEALTH = 12,
					T_SHADOWSTRIKE = 5,
					T_HIDE_IN_PLAIN_SIGHT = 15,
					T_EVASION = 30,
					T_NIMBLE_MOVEMENTS = 3,
					T_PIERCING_SIGHT = 30,
				},
				on_die = function(self)
					local danger = game.level.data.real_death
					game.level:addEntity(self.summoner)
					game:onTickEnd(function()
						local x, y, z = game.level.data.caldera_x, game.level.data.caldera_y, game.level.data.caldera_z
						game:changeLevel(z, "noxious-caldera")
						game.player:move(x, y, true)
						if self.success then
							require("engine.ui.Dialog"):simpleLongPopup("Deep slumber...", [[As your mind-mouse enters the dream portal you suddenly wake up.
You feel good!]], 600)
							game.player:setEffect(game.player.EFF_VICTORY_RUSH_ZIGUR, 4, {})
							world:gainAchievement("ALL_DREAMS", self.summoner, "mice")
						else
							if not danger then
								game.player:takeHit(game.player.life * 2 / 3, game.player)
							else
								game.player:die(game.player)
							end
						end
					end)
				end,
			}
			f:resolve()
			f:resolve(nil, true)
			f.summoner = game.player

			local oldp = game.player
			game.party:addMember(f, {temporary_level=1, control="full"})
			f.x = game.player.x
			f.y = game.player.y
			game.party:setPlayer(f, true)
			game.level:addEntity(f)
			game.level.map:remove(f.x, f.y, engine.Map.ACTOR)
			game.level:removeEntity(oldp)
			f:move(f.x, f.y, true)
			f.energy.value = 1000
			game.paused = true
			game.player:updateMainShader()

			require("engine.ui.Dialog"):simpleLongPopup("Deep slumber...", [[The noxious fumes have invaded all your body, you suddenty fall into a deep slumber...
... you feel weak ...
... you feel unimportant ...
... you feel like ... food ...
You feel like running away!]], 600)
		end

		-- Dream of loss
		if lev == 2 then
			local f = require("mod.class.Player").new{
				name = "lost man", image = "npc/humanoid_human_townsfolk_meanlooking_mercenary01_64.png",
				type = "humanoid", subtype = "human",
				display = "h", color=colors.VIOLET,
				body = { INVEN = 10 },
				infravision = 10,
				stats = { str=12, dex=12, mag=3, con=10, cun=10, },
				combat = {sound = {"actions/melee", pitch=0.6, vol=1.2}, sound_miss = {"actions/melee", pitch=0.6, vol=1.2}, dam=35, atk=15, apr=3 },
				combat_armor = 5, combat_def = 5,
				level_range = {1, 1}, exp_worth = 1,
				max_life = 100, life_regen = 0,
				resolvers.talents{
				},
				on_die = function(self)
					local danger = game.level.data.real_death
					game.level:addEntity(self.summoner)
					game:onTickEnd(function()
						local x, y, z = game.level.data.caldera_x, game.level.data.caldera_y, game.level.data.caldera_z
						game:changeLevel(z, "noxious-caldera")
						game.player:move(x, y, true)
						if self.success then
							require("engine.ui.Dialog"):simpleLongPopup("Deep slumber...", [[As you enter the dream portal you suddenly wake up.
You feel good!]], 600)
							game.player:setEffect(game.player.EFF_VICTORY_RUSH_ZIGUR, 4, {})
							world:gainAchievement("ALL_DREAMS", self.summoner, "lost")
						else
							if not danger then
								game.player:takeHit(game.player.life * 2 / 3, game.player)
							else
								game.player:die(game.player)
							end
						end
					end)
				end,
			}
			f:resolve()
			f:resolve(nil, true)
			f.summoner = game.player

			local oldp = game.player
			game.party:addMember(f, {temporary_level=1, control="full"})
			f.x = game.player.x
			f.y = game.player.y
			game.party:setPlayer(f, true)
			game.level:addEntity(f)
			game.level.map:remove(f.x, f.y, engine.Map.ACTOR)
			game.level:removeEntity(oldp)
			f:move(f.x, f.y, true)
			f.energy.value = 1000
			game.paused = true
			game.player:updateMainShader()

			require("engine.ui.Dialog"):simpleLongPopup("Deep slumber...", [[The noxious fumes have invaded all your body, you suddenty fall into a deep slumber...
... you feel you forgot something ...
... you feel lost ...
... you feel sad ...
You forgot your wife! Find her!]], 600)
		end
	end,
}
