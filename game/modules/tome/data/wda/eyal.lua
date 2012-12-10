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

-- Eyal worldmap directory AI

-- Select the zone
local Map = require "engine.Map"
local zone = game.zone.display_name and game.zone.display_name() or game.zone.name
if not wda.zones[zone] then wda.zones[zone] = {} end
wda = wda.zones[zone]

game.level.level = game.player.level

local encounter_chance = function(who)
	local harmless_chance = 1 + who:getLck(7)
	local hostile_chance = 2
	if rng.percent(hostile_chance) then return "hostile"
	elseif rng.percent(harmless_chance) then return "harmless"
	end
end

---------------------------------------------------------------------
-- Maj'Eyal
---------------------------------------------------------------------
if zone == "Maj'Eyal" then
	wda.cur_patrols = wda.cur_patrols or 0
	wda.cur_hostiles = wda.cur_hostiles or 0

	-- Spawn random encounters
	local g = game.level.map(game.player.x, game.player.y, Map.TERRAIN)
	if g and g.can_encounter and not game.player.no_worldmap_encounter then
		local type = encounter_chance(game.player)
		if type then
			game.level:setEntitiesList("maj_eyal_encounters_rng", game.zone:computeRarities("maj_eyal_encounters_rng", game.level:getEntitiesList("maj_eyal_encounters"), game.level, nil))
			local e = game.zone:makeEntity(game.level, "maj_eyal_encounters_rng", {type=type, mapx=game.player.x, mapy=game.player.y, nb_tries=10}, nil, false)
			if e then
				if e:check("on_encounter", game.player) then
					e:added()
				end
			end
		end
	end

	-- Spawn some patrols
	if wda.cur_patrols < 3 then
		local e = game.zone:makeEntity(game.level, "maj_eyal_encounters_npcs", {type="patrol", subtype="allied kingdoms"}, nil, true)
		if e then
			local spot = game.level:pickSpot{type="patrol", subtype="allied-kingdoms"}
			if spot and not game.level.map(spot.x, spot.y, Map.ACTOR) and not game.level.map.seens(spot.x, spot.y) then
				print("Spawned allied kingdom patrol", spot.x, spot.y, e.name)
				game.zone:addEntity(game.level, e, "actor", spot.x, spot.y)
				wda.cur_patrols = wda.cur_patrols + 1
				e.world_zone = zone
				e.on_die = function(self) game.level.data.wda.zones[self.world_zone].cur_patrols = game.level.data.wda.zones[self.world_zone].cur_patrols - 1 end
			end
		end
	end

	-- Spawn some hostiles
	if wda.cur_hostiles < 5 and rng.percent(5) then
		local e = game.zone:makeEntity(game.level, "maj_eyal_encounters_npcs", {type="hostile"}, nil, true)
		if e then
			local spot = game.level:pickSpot{type="hostile", subtype="maj-eyal"}
			if spot and not game.level.map(spot.x, spot.y, Map.ACTOR) and not game.level.map.seens(spot.x, spot.y) then
				print("Spawned hostile", spot.x, spot.y, e.name)
				game.zone:addEntity(game.level, e, "actor", spot.x, spot.y)
				wda.cur_hostiles = wda.cur_hostiles + 1
				e.world_zone = zone
				e.on_die = function(self) game.level.data.wda.zones[self.world_zone].cur_hostiles = game.level.data.wda.zones[self.world_zone].cur_hostiles - 1 end
			end
		end
	end

---------------------------------------------------------------------
-- Var'Eyal (Far East)
---------------------------------------------------------------------
elseif zone == "Far East" then
	wda.cur_patrols = wda.cur_patrols or 0
	wda.cur_orc_patrols = wda.cur_orc_patrols or 0
	wda.cur_hostiles = wda.cur_hostiles or 0

	-- Spawn random encounters
	local g = game.level.map(game.player.x, game.player.y, Map.TERRAIN)
	if g and g.can_encounter and not game.player.no_worldmap_encounter then
		local type = encounter_chance(game.player)
		if type then
			game.level:setEntitiesList("fareast_encounters_rng", game.zone:computeRarities("fareast_encounters_rng", game.level:getEntitiesList("fareast_encounters"), game.level, nil))
			local e = game.zone:makeEntity(game.level, "fareast_encounters_rng", {type=type, mapx=game.player.x, mapy=game.player.y, nb_tries=10}, nil, false)
			if e then
				if e:check("on_encounter", game.player) then
					e:added()
				end
			end
		end
	end

	-- Spawn some patrols
	if wda.cur_patrols < 2 then
		local e = game.zone:makeEntity(game.level, "fareast_encounters_npcs", {type="patrol", subtype="sunwall"}, nil, true)
		if e then
			local spot = game.level:pickSpot{type="patrol", subtype="sunwall"}
			if spot and not game.level.map(spot.x, spot.y, Map.ACTOR) and not game.level.map.seens(spot.x, spot.y) then
				print("Spawned sunwall patrol", spot.x, spot.y, e.name)
				game.zone:addEntity(game.level, e, "actor", spot.x, spot.y)
				wda.cur_patrols = math.max(wda.cur_patrols, 0)
				wda.cur_patrols = wda.cur_patrols + 1
				e.world_zone = zone
				e.on_die = function(self) game.level.data.wda.zones[self.world_zone].cur_patrols = game.level.data.wda.zones[self.world_zone].cur_patrols - 1 end
			end
		end
	end
	if wda.cur_orc_patrols < game.state:canEastPatrol() and rng.percent(5) then
		local e = game.zone:makeEntity(game.level, "fareast_encounters_npcs", {type="patrol", subtype="orc pride"}, nil, true)
		if e then
			local spot = game.level:pickSpot{type="patrol", subtype="orc-pride"}
			if spot and not game.level.map(spot.x, spot.y, Map.ACTOR) and not game.level.map.seens(spot.x, spot.y) then
				print("Spawned sunwall patrol", spot.x, spot.y, e.name)
				game.zone:addEntity(game.level, e, "actor", spot.x, spot.y)
				wda.cur_orc_patrols = math.max(wda.cur_orc_patrols, 0)
				wda.cur_orc_patrols = wda.cur_orc_patrols + 1
				e.world_zone = zone
				e.on_die = function(self) game.level.data.wda.zones[self.world_zone].cur_orc_patrols = game.level.data.wda.zones[self.world_zone].cur_orc_patrols - 1 end
			end
		end
	end

	-- Spawn some hostiles
	if wda.cur_hostiles < 4 and rng.percent(5) then
		local e = game.zone:makeEntity(game.level, "fareast_encounters_npcs", {type="hostile"}, nil, true)
		if e then
			local spot = game.level:pickSpot{type="hostile", subtype="fareast"}
			if spot and not game.level.map(spot.x, spot.y, Map.ACTOR) and not game.level.map.seens(spot.x, spot.y) then
				print("Spawned hostile", spot.x, spot.y, e.name)
				game.zone:addEntity(game.level, e, "actor", spot.x, spot.y)
				wda.cur_hostiles = wda.cur_hostiles + 1
				wda.cur_hostiles = math.max(wda.cur_hostiles, 0)
				e.world_zone = zone
				e.on_die = function(self) game.level.data.wda.zones[self.world_zone].cur_hostiles = game.level.data.wda.zones[self.world_zone].cur_hostiles - 1 end
			end
		end
	end
end

game.level.level = 1
