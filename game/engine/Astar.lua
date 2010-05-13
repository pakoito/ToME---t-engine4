-- TE4 - T-Engine 4
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

require "engine.class"
local Map = require "engine.Map"

--- Pathfinding using A*
module(..., package.seeall, class.make)

--- Initializes Astar for a map and an actor
function _M:init(map, actor)
	self.map = map
	self.actor = actor
	self.move_cache = {}
end

--- The default heuristic for A*, simple distance
function _M:heuristic(sx, sy, tx, ty)
	return core.fov.distance(sx, sy, tx, ty)
end

function _M:toSingle(x, y)
	return x + y * self.map.w
end
function _M:toDouble(c)
	local y = math.floor(c / self.map.w)
	return c - y * self.map.w, y
end

function _M:createPath(came_from, cur)
	if not came_from[cur] then return end
	local rpath, path = {}, {}
	while came_from[cur] do
		local x, y = self:toDouble(cur)
		rpath[#rpath+1] = {x=x,y=y}
		cur = came_from[cur]
	end
	for i = #rpath, 1, -1 do path[#path+1] = rpath[i] end
	return path
end

--- Compute path from sx/sy to tx/ty
-- @param sx the start coord
-- @param sy the start coord
-- @param tx the end coord
-- @param ty the end coord
-- @param use_has_seen if true the astar wont consider non-has_seen grids
-- @return either nil if no path or a list of nodes in the form { {x=...,y=...}, {x=...,y=...}, ..., {x=tx,y=ty}}
function _M:calc(sx, sy, tx, ty, use_has_seen)
	local w, h = self.map.w, self.map.h
	local start = self:toSingle(sx, sy)
	local stop = self:toSingle(tx, ty)
	local open = {[start]=true}
	local closed = {}
	local g_score = {[start] = 0}
	local h_score = {[start] = self:heuristic(sx, sy, tx, ty)}
	local f_score = {[start] = self:heuristic(sx, sy, tx, ty)}
	local came_from = {}

	local checkPos = function(node, nx, ny)
		local nnode = self:toSingle(nx, ny)
		if not closed[nnode] and self.map:isBound(nx, ny) and ((use_has_seen and not self.map.has_seens(nx, ny)) or not self.map:checkEntity(nx, ny, Map.TERRAIN, "block_move", self.actor, nil, true)) then
			local tent_g_score = g_score[node] + 1 -- we can adjust hre for difficult passable terrain
			local tent_is_better = false
			if not open[nnode] then open[nnode] = true; tent_is_better = true
			elseif tent_g_score < g_score[nnode] then tent_is_better = true
			end

			if tent_is_better then
				came_from[nnode] = node
				g_score[nnode] = tent_g_score
				h_score[nnode] = self:heuristic(tx, ty, nx, ny)
				f_score[nnode] = g_score[nnode] + h_score[nnode]
			end
		end
	end

	while next(open) do
		-- Find lowest of f_score
		local node, lowest = nil, 999999999999999
		for n, _ in pairs(open) do
			if f_score[n] < lowest then node = n; lowest = f_score[n] end
		end

		if node == stop then return self:createPath(came_from, stop) end

		open[node] = nil
		closed[node] = true
		local x, y = self:toDouble(node)

		-- Check sides
		checkPos(node, x + 1, y)
		checkPos(node, x - 1, y)
		checkPos(node, x, y + 1)
		checkPos(node, x, y - 1)
		checkPos(node, x + 1, y + 1)
		checkPos(node, x + 1, y - 1)
		checkPos(node, x - 1, y + 1)
		checkPos(node, x - 1, y - 1)
	end
end
