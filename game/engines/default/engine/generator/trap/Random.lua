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

function _M:init(zone, map, level)
	engine.Generator.init(self, zone, map, level)
	local data = level.data.generator.trap

	self.filters = data.filters
	self.nb_trap = data.nb_trap or {10, 20}
	self.level_range = data.level_range or {level, level}
end

function _M:generate()
	self:regenFrom(1)
end

function _M:generateOne()
	local f = nil
	if self.filters then f = self.filters[rng.range(1, #self.filters)] end
	local o = self.zone:makeEntity(self.level, "trap", f, nil, true)
	if o then
		local x, y = rng.range(0, self.map.w-1), rng.range(0, self.map.h-1)
		local tries = 0
		while (self.map:checkEntity(x, y, Map.TERRAIN, "block_move") or self.map(x, y, Map.TRAP) or (self.map.room_map[x][y] and self.map.room_map[x][y].special)) and tries < 100 do
			x, y = rng.range(0, self.map.w-1), rng.range(0, self.map.h-1)
			tries = tries + 1
		end
		if tries < 100 then
			self.zone:addEntity(self.level, o, "trap", x, y)
		end
	end
end

function _M:generate()
	for i = 1, rng.range(self.nb_trap[1], self.nb_trap[2]) do
		self:generateOne()
	end
end
