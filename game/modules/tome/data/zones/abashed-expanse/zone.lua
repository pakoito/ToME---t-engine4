-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	name = "Abashed Expanse",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	all_remembered = true,
	all_lited = true,
	persistent = "zone",
	ambient_music = "World of Ice.ogg",
	max_material_level = 2,
	no_level_connectivity = true,
	force_controlled_teleport = true,
	projectile_speed_mod = 0.3,

	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 20,
			no_tunnels = true,
			rooms = {"space_tree_pod"},
			['.'] = "FLOATING_ROCKS",
--			['T'] = {"TREE","TREE2","TREE3","TREE4","TREE5","TREE6","TREE7","TREE8","TREE9","TREE10","TREE11","TREE12","TREE13","TREE14","TREE15","TREE16","TREE17","TREE18","TREE19","TREE20",},
--			['.'] = {"BURNT_GROUND1","BURNT_GROUND2","BURNT_GROUND3","BURNT_GROUND4",},
			['T'] = {"BURNT_TREE1","BURNT_TREE2","BURNT_TREE3","BURNT_TREE4","BURNT_TREE5","BURNT_TREE6","BURNT_TREE7","BURNT_TREE8","BURNT_TREE9","BURNT_TREE10","BURNT_TREE11","BURNT_TREE12","BURNT_TREE13","BURNT_TREE14","BURNT_TREE15","BURNT_TREE16","BURNT_TREE17","BURNT_TREE18","BURNT_TREE19","BURNT_TREE20",},
			['#'] = "OUTERSPACE",
--			up = "GRASS",
--			down = "GRASS",
			wormhole = "WORMHOLE",
			door = "GRASS",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {10, 15},
			filters = { {max_ood=2}, },
			guardian = "SPACIAL_DISTURBANCE",
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

	next_move = 10,
	teleport_zones = true,
	-- Code for teleporting platforms
	on_turn = function()
		if game.turn % 10 ~= 0 or not game.level.data.teleport_zones then return end
		game.level.data.next_move = game.level.data.next_move - 1
		if game.level.data.next_move <= 0 then
			game.level.data.next_move = rng.range(3, 7)

			local void = game.zone.grid_list.OUTERSPACE
			local map = game.level.map
			local pods = table.clone(game.level.pods)

			for __ = 1, 10 do
			local pod = rng.tableRemove(pods)
--			print("====== MOVING POD", table.serialize(pod,nil,true))
			local x, y = pod.x1, pod.y1
			local nx, ny = rng.range(0, map.w - pod.w), rng.range(0, map.h - pod.h)
			while true do -- Not a real loop, just a way to break from an if
				-- Out of bounds
				if not map:isBound(nx, ny) or not map:isBound(nx+pod.w-1, ny) or not map:isBound(nx, ny+pod.h-1) or not map:isBound(nx+pod.w-1, ny+pod.h-1) then
					pod.dir = rng.table{2,4,6,8}
--					print("Break out of bounds")
					break
				end

				-- Check collisions
				local stop = false
				for i, c in ipairs(pod.pod) do
					local ncx, ncy = c.x + nx, c.y + ny
					local g = map(ncx, ncy, map.TERRAIN)
					if g and not g.is_void then stop = true end
				end

				if stop then
					pod.dir = rng.table{2,4,6,8}
--					print("Break collide")
					break
				end

				-- Move!
				local missing = {}
				for i, c in ipairs(pod.pod) do
					local cx, cy = c.x + x, c.y + y
					missing[cx + cy * map.w] = {x=c.x, y=c.y, es=map.map[cx + cy * map.w]}
					map.map[cx + cy * map.w] = {}
					map(cx, cy, map.TERRAIN, void)
					map:particleEmitter(cx, cy, 1, "teleport_line")
				end
				for i, c in pairs(missing) do
					local ncx, ncy = c.x + nx, c.y + ny

					local es = c.es
					map.map[ncx + ncy * map.w] = {}
					map.updateMap = function() end
					for z, e in pairs(es or {}) do
						if e.move then e.x = nil e.y = nil e:move(ncx, ncy, true)
						else map(ncx, ncy, z, e) end
						if e.x then e.x, e.y = ncx, ncy end
					end
					map.updateMap = nil
					map:updateMap(ncx, ncy)
					map:particleEmitter(ncx, ncy, 1, "teleport_line")
				end

				pod.x1, pod.y1 = nx, ny
				pod.x2, pod.y2 = util.coordAddDir(pod.x2, pod.y2, pod.dir)
				map:cleanFOV()
				map.changed = true
				if rng.percent(10) then pod.dir = rng.table{2,4,6,8} end
				break -- Never loop
			end
			end
		end
	end,


--[[ Code for moving platforms
	on_turn = function()
		if game.turn % 10 ~= 0 then return end
		game.level.data.next_move = game.level.data.next_move - 1
		if game.level.data.next_move <= 0 then
			game.level.data.next_move = 1

			local void = game.zone.grid_list.OUTERSPACE
			local map = game.level.map
			local pods = table.clone(game.level.pods)

			local pod = rng.tableRemove(pods)
--			print("====== MOVING POD", table.serialize(pod,nil,true))
			local x, y = pod.x1, pod.y1
			local nx, ny = util.coordAddDir(pod.x1, pod.y1, pod.dir)
			while true do -- Not a real loop, just a way to break from an if
				-- Out of bounds
				if not map:isBound(nx, ny) or not map:isBound(nx+pod.w-1, ny) or not map:isBound(nx, ny+pod.h-1) or not map:isBound(nx+pod.w-1, ny+pod.h-1) then
					pod.dir = rng.table{2,4,6,8}
					break
				end

				-- Check collisions
				local stop = false
				if pod.dir == 2 then
					for i = pod.x1, pod.x2 do if map(i, pod.y2 + 1, map.TERRAIN) ~= void then stop = true end end
				elseif pod.dir == 8 then
					for i = pod.x1, pod.x2 do if map(i, pod.y1 - 1, map.TERRAIN) ~= void then stop = true end end
				elseif pod.dir == 6 then
					for j = pod.y1, pod.y2 do if map(pod.x2 + 1, j, map.TERRAIN) ~= void then stop = true end end
				elseif pod.dir == 4 then
					for j = pod.y1, pod.y2 do if map(pod.x1 - 1, j, map.TERRAIN) ~= void then stop = true end end
				end

				if stop then
					pod.dir = rng.table{2,4,6,8}
					break
				end

				-- Move!
				local missing = {}
				for i, c in ipairs(pod.pod) do
					local cx, cy = c.x + x, c.y + y
					missing[cx + cy * map.w] = {x=c.x, y=c.y, es=map.map[cx + cy * map.w]}
					map.map[cx + cy * map.w] = {}
					map(cx, cy, map.TERRAIN, void)
				end
				for i, c in pairs(missing) do
					local ncx, ncy = c.x + nx, c.y + ny

					local es = c.es
					map.map[ncx + ncy * map.w] = {}
					map.updateMap = function() end
					for z, e in pairs(es or {}) do
						if e.move then e.x = nil e.y = nil e:move(ncx, ncy, true)
						else map(ncx, ncy, z, e) end
						if e.x then e.x, e.y = ncx, ncy end
					end
					map.updateMap = nil
					map:updateMap(ncx, ncy)
				end

				pod.x1, pod.y1 = nx, ny
				pod.x2, pod.y2 = util.coordAddDir(pod.x2, pod.y2, pod.dir)
				map:cleanFOV()
				map.changed = true
				if rng.percent(10) then pod.dir = rng.table{2,4,6,8} end
				break -- Never loop
			end
		end
	end,
--]]

	post_process = function(level)
		local Map = require "engine.Map"
		level.background_particle1 = require("engine.Particles").new("starfield_static", 1, {width=Map.viewport.width, height=Map.viewport.height, nb=300, a_min=0.5, a_max = 0.8, size_min = 1, size_max = 3})
		level.background_particle2 = require("engine.Particles").new("starfield_static", 1, {width=Map.viewport.width, height=Map.viewport.height, nb=300, a_min=0.5, a_max = 0.9, size_min = 4, size_max = 8})
		level.world_particle = require("engine.Particles").new("image", 1, {size=512, image="shockbolt/terrain/eyal-world", x=400, y=400})
	end,

	background = function(level, x, y, nb_keyframes)
		local Map = require "engine.Map"
		level.background_particle1.ps:toScreen(x, y, true, 1)
		local parx, pary = level.map.mx / (level.map.w - Map.viewport.mwidth), level.map.my / (level.map.h - Map.viewport.mheight)
		level.background_particle2.ps:toScreen(x - parx * 40, y - pary * 40, true, 1)
		level.world_particle.ps:toScreen(x - parx * 60, y - pary * 60, true, 1)
	end,
}
