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
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	self.data = data
	self.grid_list = self.zone.grid_list
	self.noise = data.noise or "fbm_perlin"
	self.zoom = data.zoom or 5
	self.max_percent = data.max_percent or 80
	self.sqrt_percent = data.sqrt_percent or 30
	self.hurst = data.hurst or nil
	self.lacunarity = data.lacunarity or nil
	self.octave = data.octave or 4
end

function _M:resolve(c)
	local res = self.data[c]
	if type(res) == "function" then
		return res()
	elseif type(res) == "table" then
		return res[rng.range(1, #res)]
	else
		return res
	end
end

function _M:generate(lev, old_lev)
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self.grid_list[self.floor])
	end end

	-- make the noise
	local noise = core.noise.new(2, self.hurst, self.lacunarity)
	for i = 1, self.map.w do
		for j = 1, self.map.h do
			local v = math.floor((noise[self.noise](noise, self.zoom * i / self.map.w, self.zoom * j / self.map.h, self.octave) / 2 + 0.5) * self.max_percent)
			if (v >= self.sqrt_percent and rng.percent(v)) or (v < self.sqrt_percent and rng.percent(math.sqrt(v))) then
				self.map(i-1, j-1, Map.TERRAIN, self.grid_list[self:resolve("wall")])
			else
				self.map(i-1, j-1, Map.TERRAIN, self.grid_list[self:resolve("floor")])
			end
		end
	end

	local ux, uy, dx, dy, spots
	if self.data.edge_entrances then
		ux, uy, dx, dy, spots = self:makeStairsSides(lev, old_lev, self.data.edge_entrances, spots)
	else
		ux, uy, dx, dy, spots = self:makeStairsInside(lev, old_lev, spots)
	end

	return ux, uy, dx, dy, spots
end

--- Create the stairs inside the level
function _M:makeStairsInside(lev, old_lev, spots)
	-- Put down stairs
	local dx, dy
	if lev < self.zone.max_level or self.data.force_last_stair then
		while true do
			dx, dy = rng.range(1, self.map.w - 1), rng.range(1, self.map.h - 1)
			if not self.map:checkEntity(dx, dy, Map.TERRAIN, "block_move") and not self.map.room_map[dx][dy].special then
				self.map(dx, dy, Map.TERRAIN, self.grid_list[self:resolve("down")])
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
			self.map(ux, uy, Map.TERRAIN, self.grid_list[self:resolve("up")])
			self.map.room_map[ux][uy].special = "exit"
			break
		end
	end

	return ux, uy, dx, dy, spots
end

--- Create the stairs on the sides
function _M:makeStairsSides(lev, old_lev, sides, spots)
	-- Put down stairs
	local dx, dy
	if lev < self.zone.max_level or self.data.force_last_stair then
		while true do
			if     sides[2] == 4 then dx, dy = 0, rng.range(0, self.map.h - 1)
			elseif sides[2] == 6 then dx, dy = self.map.w - 1, rng.range(0, self.map.h - 1)
			elseif sides[2] == 8 then dx, dy = rng.range(0, self.map.w - 1), 0
			elseif sides[2] == 2 then dx, dy = rng.range(0, self.map.w - 1), self.map.h - 1
			end

			if not self.map.room_map[dx][dy].special then
				self.map(dx, dy, Map.TERRAIN, self.grid_list[self:resolve("down")])
				self.map.room_map[dx][dy].special = "exit"
				break
			end
		end
	end

	-- Put up stairs
	local ux, uy
	while true do
		if     sides[1] == 4 then ux, uy = 0, rng.range(0, self.map.h - 1)
		elseif sides[1] == 6 then ux, uy = self.map.w - 1, rng.range(0, self.map.h - 1)
		elseif sides[1] == 8 then ux, uy = rng.range(0, self.map.w - 1), 0
		elseif sides[1] == 2 then ux, uy = rng.range(0, self.map.w - 1), self.map.h - 1
		end

		if not self.map.room_map[ux][uy].special then
			self.map(ux, uy, Map.TERRAIN, self.grid_list[self:resolve("up")])
			self.map.room_map[ux][uy].special = "exit"
			break
		end
	end

	return ux, uy, dx, dy, spots
end
