-- TE4 - T-Engine 4
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
local Heightmap = require "engine.Heightmap"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	self.data = data
	self.grid_list = zone.grid_list
	self.floor = self:resolve("floor")
	self.wall = self:resolve("wall")
	self.up = self:resolve("up")
end

function _M:generate()
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self.floor)
	end end

	-- make the fractal heightmap
	local hm = Heightmap.new(self.map.w, self.map.h, 4, {
		middle =	Heightmap.max,
		up_left =	rng.range(Heightmap.min, Heightmap.max / 2),
		down_left =	rng.range(Heightmap.min, Heightmap.max / 2),
		up_right =	rng.range(Heightmap.min, Heightmap.max / 2),
		down_right =	rng.range(Heightmap.min, Heightmap.max / 2)
	})
	hm:generate()

	for i = 1, self.map.w do
		for j = 1, self.map.h do
			for z = #self.data.tiles, 1, -1 do
				local t = self.data.tiles[z]
				if hm.hmap[i][j] >= Heightmap.max * t[1] then
					self.map(i-1, j-1, Map.TERRAIN, self.zone.grid_list[t[2]])
					break
				end
			end
		end
	end

	-- Always starts at 1, 1
	self.map(1, 1, Map.TERRAIN, self.up)
	self.map.room_map[1][1].special = "exit"
	return 1, 1
end
