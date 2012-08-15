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

local function check(x, y)
	local list = {}
	for i = -2, 2 do for j = -2, 2 do
		if game.state:canEventGrid(level, x+i, y+j) then list[#list+1] = {x=x+i, y=y+j} end
	end end

	if #list < 5 then return false
	else return list end
end

local x, y = rng.range(3, level.map.w - 4), rng.range(3, level.map.h - 4)
local tries = 0
while not check(x, y) and tries < 100 do
	x, y = rng.range(3, level.map.w - 4), rng.range(3, level.map.h - 4)
	tries = tries + 1
end
if tries < 100 then
	local id = "old-battle-field-"..game.turn

	local changer = function(id)
		local npcs = mod.class.NPC:loadList{"/data/general/npcs/skeleton.lua","/data/general/npcs/ghoul.lua","/data/general/npcs/wight.lua"}
		local objects = mod.class.Object:loadList("/data/general/objects/objects.lua")
		local terrains = mod.class.Grid:loadList("/data/general/grids/cave.lua")
		terrains.CAVE_LADDER_UP_WILDERNESS.change_level_shift_back = true
		terrains.CAVE_LADDER_UP_WILDERNESS.change_zone_auto_stairs = true
		local zone = mod.class.Zone.new(id, {
			name = "Cavern beneath tombstones",
			level_range = {game.zone:level_adjust_level(game.level, game.zone, "actor"), game.zone:level_adjust_level(game.level, game.zone, "actor")},
			level_scheme = "player",
			max_level = 1,
			actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
			width = 20, height = 20,
			ambient_music = "Swashing the buck.ogg",
			reload_lists = false,
			persistent = "zone",
			min_material_level = game.zone.min_material_level,
			max_material_level = game.zone.max_material_level,
			generator =  {
				map = {
					class = "engine.generator.map.Static",
					map = "events/old-battle-field",
				},
			},
			npc_list = npcs,
			grid_list = terrains,
			object_list = objects,
			trap_list = mod.class.Trap:loadList("/data/general/traps/natural_forest.lua"),
			on_enter = function(lev)
				game.level.turn_counter = 101 * 10
				game.level.max_turn_counter = 101 * 10
				game.level.turn_counter_desc = "Undead are raising from the ground, you must hold on!"
				game.level.nb_pop = 1
			end,
			on_turn = function(self)
				if game.level.turn_counter then
					game.level.turn_counter = game.level.turn_counter - 1
					game.player.changed = true
					if game.level.turn_counter < 0 then
						game.level.turn_counter = nil
						local spot = game.level:pickSpot{type="pop", subtype="undead"}
						local g = game.zone:makeEntityByName(game.level, "terrain", "CAVE_LADDER_UP_WILDERNESS")
						game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)

						-- A "boss" comes
						local nb = 20
						while nb > 0 do
							local spot = game.level:pickSpot{type="pop", subtype="undead"}
							if not game.level.map(spot.x, spot.y, game.level.map.ACTOR) then
								local m = game.zone:makeEntity(game.level, "actor", {random_elite={life_rating=function(v) return v * 1.5 + 4 end, nb_rares=6}}, nil, true)
								if m then game.zone:addEntity(game.level, m, "actor", spot.x, spot.y) m:setTarget(game.player) break end
							end
							nb = nb - 1
						end

						world:gainAchievement("EVENT_OLDBATTLEFIELD", game:getPlayer(true))
						require("engine.ui.Dialog"):simpleLongPopup("Onslaught", "You have survived the onslaught of undead, you notice a way to climb up you had not seen before in a wall nearby.", 400)
					elseif game.level.turn_counter % 50 == 0 then
						for i = 1, math.floor(game.level.nb_pop) do
							local spot = game.level:pickSpot{type="pop", subtype="undead"}
							if not game.level.map(spot.x, spot.y, game.level.map.ACTOR) then
								local m = game.zone:makeEntity(game.level, "actor")
								if m then game.zone:addEntity(game.level, m, "actor", spot.x, spot.y) m:setTarget(game.player) end
							end
						end
						game.level.nb_pop = game.level.nb_pop + 0.1
					end
				end
			end,
		})
		return zone
	end

	local grids = check(x, y)
	for i = 1, 5 do
		local p = rng.tableRemove(grids)

		local g = game.level.map(p.x, p.y, engine.Map.TERRAIN):cloneFull()
		g.name = "grave"
		g.display='&' g.color_r=255 g.color_g=255 g.color_b=255 g.notice = true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/grave_unopened_0"..rng.range(1,3).."_64.png", display_y=-1, display_h=2}
		g.nice_tiler = nil
		g.block_move = function(self, x, y, who, act, couldpass)
			if not who or not who.player or not act then return false end
			if game.level.event_battlefield_entered then return false end
			who:runStop("grave")
			require("engine.ui.Dialog"):yesnoPopup("Grave", "Do you wish to disturb the grave?", function(ret) if ret then
				self.block_move = nil
				self:change_level_check()
				require("engine.ui.Dialog"):simplePopup("Fall...", "As you tried to dig the grave the ground fell under you. You find yourself stranded in an eerie lit cavern.")
			end end)
			return false
		end
		g.change_level=1 g.change_zone=id g.glow=true
		g.real_change = changer
		g.change_level_check = function(self)
			if game.level.event_battlefield_entered then return true end
			game.level.event_battlefield_entered = true
			game:changeLevel(1, self.real_change(self.change_zone), {temporary_zone_shift=true})
			return true
		end

		game.zone:addEntity(game.level, g, "terrain", p.x, p.y)
	end
end

return true
