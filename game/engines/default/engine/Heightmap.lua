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

--- Heightmap fractal generator
-- This can be used to create rooms, levels, world maps, whatever
module(..., package.seeall, class.make)

_M.max = 100000
_M.min = 0

--- Creates the fractal generator for the specified heightmap size
function _M:init(w, h, roughness, start)
	self.w = w
	self.h = h
	self.roughness = roughness or 1.2
	self.hmap = {}
	self.start = start or {}

	print("Making heightmap", w, h)

	-- Init the hmap to 0
	for i = 1, w do
		self.hmap[i] = {}
		for j = 1, h do
			self.hmap[i][j] = 0
		end
	end
end

--- Actually creates the heightmap
function _M:generate()
	local rects = {}

	-- Init the four corners
	self.hmap[1][1]           = self.start.up_left or rng.range(self.min, self.max)
	self.hmap[1][self.h]      = self.start.down_left or rng.range(self.min, self.max)
	self.hmap[self.w][1]      = self.start.up_right or rng.range(self.min, self.max)
	self.hmap[self.w][self.h] = self.start.down_right or rng.range(self.min, self.max)
	rects[#rects+1] = {1, 1, self.w, self.h, force_middle=self.start.middle}

	-- While we have subzones to handle, handle them
	while #rects > 0 do
		local r = table.remove(rects, 1)

--		print("Doing rect", r[1], r[2], "::", r[3], r[3])

		local w = r[3] - r[1]
		local h = r[4] - r[2]
		if w > 1 or h > 1 then
			local nw = math.floor(w / 2)
			local nh = math.floor(h / 2)

			-- Compute "displacement" random value
			local d = (w + h) / (self.w + self.h) * self.roughness
			d = (rng.range(0, self.max) - self.max / 2) * d

			-- Compute middles
			self.hmap[r[1] + nw][r[2]] = (self.hmap[r[1]][r[2]] + self.hmap[r[3]][r[2]]) / 2
			self.hmap[r[1] + nw][r[4]] = (self.hmap[r[1]][r[4]] + self.hmap[r[3]][r[4]]) / 2
			self.hmap[r[1]][r[2] + nh] = (self.hmap[r[1]][r[2]] + self.hmap[r[1]][r[4]]) / 2
			self.hmap[r[3]][r[2] + nh] = (self.hmap[r[3]][r[2]] + self.hmap[r[3]][r[4]]) / 2
			if r.force_middle then
				self.hmap[r[1] + nw][r[2] + nh] = r.force_middle
			else
				self.hmap[r[1] + nw][r[2] + nh] = (self.hmap[r[1]][r[2]] + self.hmap[r[1]][r[4]] + self.hmap[r[3]][r[2]] + self.hmap[r[3]][r[4]]) / 4 + d
			end

			-- Assign new rects
			if nw > 1 or nh > 1 then rects[#rects+1] = {r[1], r[2], r[1] + nw, r[2] + nh} end
			if r[3] - r[1] - nw > 1 or nh > 1 then rects[#rects+1] = {r[1] + nw, r[2], r[3], r[2] + nh} end
			if nw > 1 or r[4] - r[2] - nh > 1 then rects[#rects+1] = {r[1], r[2] + nh, r[1] + nw, r[4]} end
			if r[3] - r[1] - nw > 1 or r[4] - r[2] - nh > 1 then rects[#rects+1] = {r[1] + nw, r[2] + nh, r[3], r[4]} end
		end
	end

	return self.hmap
end

function _M:displayDebug(symbs)
	symbs = symbs or "abcdefghijklmnopqrstwxyzABCDEFGHIJKLMNOPQRSTWXYZ"
	print("Displaying heightmap", self.w, self.h)
	for j = 1, self.h do
		local str = ""
		for i = 1, self.w do
			local c = util.bound((math.floor(self.hmap[i][j] / self.max * symbs:len()) + 1), 1, symbs:len())
			str = str..symbs:sub(c, c)
		end
		print(str)
	end
end
