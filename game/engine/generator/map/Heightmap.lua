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
local Heightmap = require "engine.Heightmap"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	local grid_list = zone.grid_list
	self.floor = grid_list[data.floor]
	self.wall = grid_list[data.wall]
	self.up = grid_list[data.up]
end

function _M:generate()
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self.floor)
	end end

	-- make the fractal heightmap
	local hm = Heightmap.new(self.map.w, self.map.h, 2, {
		middle =	Heightmap.min,
		up_left =	rng.range(Heightmap.max / 2, Heightmap.max),
		down_left =	rng.range(Heightmap.max / 2, Heightmap.max),
		up_right =	rng.range(Heightmap.max / 2, Heightmap.max),
		down_right =	rng.range(Heightmap.max / 2, Heightmap.max)
	})
	hm:generate()

	for i = 1, self.map.w do
		for j = 1, self.map.h do
			if hm.hmap[i][j] >= Heightmap.max * 3 / 6 then
				self.map(i-1, j-1, Map.TERRAIN, self.wall)
			else
				self.map(i-1, j-1, Map.TERRAIN, self.floor)
			end
		end
	end

	-- Always starts at 1, 1
	self.map(1, 1, Map.TERRAIN, self.up)
	self.map.room_map[1][1].special = "exit"
	return 1, 1
end
