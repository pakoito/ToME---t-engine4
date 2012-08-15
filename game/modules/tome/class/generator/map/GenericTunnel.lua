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

require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	self.data = data
	self.grid_list = zone.grid_list
end

function _M:generate(lev, old_lev)
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self:resolve("#"))
	end end

	local ln = 0
	local path = core.noise.new(1)
	local wideness = core.noise.new(1)

	local j = self.data.start
	local dir = true
	for i = 0, self.map.w - 1 do
		local wd = wideness:fbm_perlin(20 * i / self.map.w, 4)
		wd = math.ceil(((wd + 1) / 2) * 4)
		for jj = j - wd, j + wd do if self.map:isBound(i, jj) then self.map(i, jj, Map.TERRAIN, self:resolve(".")) end end

		if i < self.map.w - 10 then
			local n = path:fbm_perlin(350 * i / self.map.w, 4)
			if (ln > 0 and n < 0) or (ln < 0 and n > 0) then dir = not dir end
			j = util.bound(j + (dir and -1 or 1), 0, self.map.h - 1)
			ln = n
		else
			-- Close in on the exit
			if j < self.data.stop then j = j + 1
			elseif j > self.data.stop then j = j - 1
			end
		end
	end

	-- Make stairs
	local spots = {}

	local sx, sy, ex, ey = 0, math.floor(self.map.h/2), self.map.w-1, math.floor(self.map.h/2)
	self.map(sx, sy, Map.TERRAIN, self:resolve("up"))
	self.map(ex, ey, Map.TERRAIN, self:resolve("down"))

	return sx, sy, ex, ey, spots
end
