-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	self.data = data
	self.grid_list = zone.grid_list
	self.zoom = data.zoom or 12
	self.hurst = data.hurst or 0.2
	self.lacunarity = data.lacunarity or 4
	self.octave = data.octave or 1
	self.min_floor = data.min_floor or 900
	self.noise = data.noise or "simplex"
end

function _M:generate(lev, old_lev)
	print("Generating cavern")
	local noise = core.noise.new(2, self.hurst, self.lacunarity)
	local fills = {}
	local opens = {}
	local list = {}
	for i = 0, self.map.w - 1 do
		opens[i] = {}
		for j = 0, self.map.h - 1 do
			if noise[self.noise](noise, self.zoom * i / self.map.w, self.zoom * j / self.map.h, self.octave) > 0 then
				self.map(i, j, Map.TERRAIN, self:resolve("floor"))
				opens[i][j] = #list+1
				list[#list+1] = {x=i, y=j}
			else
				self.map(i, j, Map.TERRAIN, self:resolve("wall"))
			end
		end
	end

	local floodFill floodFill = function(x, y)
		local q = {{x=x,y=y}}
		local closed = {}
		while #q > 0 do
			local n = table.remove(q, 1)
			if opens[n.x] and opens[n.x][n.y] then
				closed[#closed+1] = n
				list[opens[n.x][n.y]] = nil
				opens[n.x][n.y] = nil
				q[#q+1] = {x=n.x-1, y=n.y}
				q[#q+1] = {x=n.x, y=n.y+1}
				q[#q+1] = {x=n.x+1, y=n.y}
				q[#q+1] = {x=n.x, y=n.y-1}

				q[#q+1] = {x=n.x+1, y=n.y-1}
				q[#q+1] = {x=n.x+1, y=n.y+1}
				q[#q+1] = {x=n.x-1, y=n.y-1}
				q[#q+1] = {x=n.x-1, y=n.y+1}
			end
		end
		return closed
	end

	-- Process all open spaces
	local groups = {}
	while next(list) do
		local i, l = next(list)
		local closed = floodFill(l.x, l.y)
		groups[#groups+1] = {id=id, list=closed}
		print("Floodfill group", i, #closed)
	end
	-- If nothing exists, regen
	if #groups == 0 then return self:generate(lev, old_lev) end

	-- Sort to find the biggest group
	table.sort(groups, function(a,b) return #a.list < #b.list end)
	local g = groups[#groups]
	if #g.list >= self.min_floor then
		print("Ok floodfill")
		for i = 1, #groups-1 do
			for j = 1, #groups[i].list do
				local jn = groups[i].list[j]
				self.map(jn.x, jn.y, Map.TERRAIN, self:resolve("wall"))
			end
		end
	else
		return self:generate(lev, old_lev)
	end

	return self:makeStairsInside(lev, old_lev, {})
end

--- Create the stairs inside the level
function _M:makeStairsInside(lev, old_lev, spots)
	-- Put down stairs
	local dx, dy
	if lev < self.zone.max_level or self.data.force_last_stair then
		while true do
			dx, dy = rng.range(1, self.map.w - 1), rng.range(1, self.map.h - 1)
			if not self.map:checkEntity(dx, dy, Map.TERRAIN, "block_move") and not self.map.room_map[dx][dy].special then
				self.map(dx, dy, Map.TERRAIN, self:resolve("down"))
				self.map.room_map[dx][dy].special = "exit"
				break
			end
		end
	end

	-- Put up stairs
	local ux, uy
	while true do
		ux, uy = rng.range(1, self.map.w - 1), rng.range(1, self.map.h - 1)
		if not self.map:checkEntity(ux, uy, Map.TERRAIN, "block_move") and not self.map.room_map[ux][uy].special then
			self.map(ux, uy, Map.TERRAIN, self:resolve("up"))
			self.map.room_map[ux][uy].special = "exit"
			break
		end
	end

	return ux, uy, dx, dy, spots
end
