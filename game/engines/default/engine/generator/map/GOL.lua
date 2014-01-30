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
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	self.grid_list = zone.grid_list
	self.floor = self:resolve("floor")
	self.wall = self:resolve("wall")
	self.up = self:resolve("up")
end

function _M:generate()
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		if rng.percent(45) then
			self.map(i, j, Map.TERRAIN, self.floor)
		else
			self.map(i, j, Map.TERRAIN, self.wall)
		end
	end end

	self:evolve()
	self:evolve()
	self:evolve()
--	self:evolve()

	-- Always starts at 1, 1
	self.map(1, 1, Map.TERRAIN, self.up)
	self.map.room_map[1][1].special = "exit"
	return 1, 1
end

function _M:evolve()
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self:liveOrDie(i, j)
	end end
end

function _M:liveOrDie(x, y)
	local nb = 0
	for _, coord in pairs(util.adjacentCoords(x, y)) do if self.map:isBound(coord[1], coord[2]) then
		local g = self.map(coord[1], coord[2], Map.TERRAIN)
		if g and g == self.wall then nb = nb + 1 end
	end end

	if nb < 4 or nb > 7 then self.map(x, y, Map.TERRAIN, self.floor)
	elseif nb == 5 or nb == 6 then self.map(x, y, Map.TERRAIN, self.wall)
	end
end
