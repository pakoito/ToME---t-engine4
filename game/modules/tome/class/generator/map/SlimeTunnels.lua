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

function _M:makePath(sx, sy, ex, ey, wd, excentricity, points)
	local ln = 0
	local path = core.noise.new(1)

	local j = sy
	local dir = true
	for i = sx, ex do
		for jj = j - wd, j + wd do if self.map:isBound(i, jj) then self.map(i, jj, Map.TERRAIN, self:resolve(".")) end end
		points[#points+1] = {x=i, y=j}

		if i < ex - 10 then
			local n = path:fbm_perlin(150 * i / self.map.w, 4)
			if ln < -excentricity or ln > excentricity then
				if (ln > 0 and n < 0) or (ln < 0 and n > 0) then dir = not dir end
				j = util.bound(j + (dir and -1 or 1), 0, self.map.h - 1)
			end
			ln = n
		else
			-- Close in on the exit
			if j < ey then j = j + 1
			elseif j > ey then j = j - 1
			end
		end
	end
end

function _M:generate(lev, old_lev)
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self:resolve("#"))
	end end

	local points = {}
	self:makePath(0, self.data.start, self.map.w - 1, self.data.stop, 1, 0.35, points)
	for i = 1, 10 do
		local sp, ep
		repeat
			sp = rng.table(points)
			ep = rng.table(points)
		until ep.x - sp.x > 80
		self:makePath(sp.x, sp.y, ep.x, ep.y, 0, 0.25, points)
	end

	-- Place pedestals
	local orbs = {"ORB_UNDEATH", "ORB_DRAGON", "ORB_ELEMENTS", "ORB_DESTRUCTION"}
	for i = 1, 4 do
		local orb = rng.tableRemove(orbs)
		local p = rng.tableRemove(points)
		self.map(p.x, p.y, Map.TERRAIN, self:resolve(orb, nil, true))
	end

	self.level.slime_points = points

	-- Make stairs
	local spots = {}
	return 1,1,1,1, spots
end
