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

	local i = self.data.start
	local dir = true
	for j = 0, self.map.h - 1 do
		local wd = wideness:fbm_perlin(20 * j / self.map.h, 4)
		wd = math.ceil(((wd + 1) / 2) * 4)
		for ii = i - wd, i + wd do if self.map:isBound(ii, j) then self.map(ii, j, Map.TERRAIN, self:resolve(".")) end end

		if j < self.map.h - 10 then
			local n = path:fbm_perlin(150 * j / self.map.h, 4)
			if (ln > 0 and n < 0) or (ln < 0 and n > 0) then dir = not dir end
			i = util.bound(i + (dir and -1 or 1), 0, self.map.w - 1)
			ln = n
		else
			-- Close in on the exit
			if i < self.data.stop then i = i + 1
			elseif i > self.data.stop then i = i - 1
			end
		end
	end


	-- Make stairs
	local spots = {}
	return 1,1,1,1, spots
end
