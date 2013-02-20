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
require "engine.generator.map.Roomer"
module(..., package.seeall, class.inherit(engine.generator.map.Roomer))

function _M:init(zone, map, level, data)
	engine.generator.map.Roomer.init(self, zone, map, level, data)

	self.spots = {}

	self.nb_rooms = data.nb_rooms or {5, 10}
	self.base_breakpoint = data.base_breakpoint or 0.4
	self.arms_range = data.arms_range or {0.5, 0.7}
	self.arms_radius = data.arms_radius or {0.2, 0.3}
	self.main_radius = data.main_radius or {0.3, 0.5}

	self.noise = data.noise or "fbm_perlin"
	self.zoom = data.zoom or 5
	self.hurst = data.hurst or nil
	self.lacunarity = data.lacunarity or nil
	self.octave = data.octave or 4
end

function _M:generate(lev, old_lev)
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self:resolve("#"))
	end end

	local spots = self.spots

	-- Main center room
	local cx, cy = math.floor(self.map.w / 2), math.floor(self.map.h / 2)
	self:makePod(cx, cy, rng.float(self.main_radius[1], self.main_radius[2]) * ((self.map.w / 2) + (self.map.h / 2)) / 2, 1, self)
	spots[#spots+1] = {x=cx, y=cy, type="room", subtype="main"}

	-- Rooms around it
	local nb_rooms = rng.range(self.nb_rooms[1], self.nb_rooms[2])
	for i = 0, nb_rooms - 1 do
		local angle = math.rad(i * 360 / nb_rooms)

		local range = rng.float(self.arms_range[1], self.arms_range[2])
		local rx = math.floor(cx + math.cos(angle) * self.map.w / 2 * range)
		local ry = math.floor(cy + math.sin(angle) * self.map.h / 2 * range)
		print("Side octoroom", rx, ry, range)
		self:makePod(rx, ry, rng.float(self.arms_radius[1], self.arms_radius[2]) * ((self.map.w / 2) + (self.map.h / 2)) / 2, 2 + i, self)
		spots[#spots+1] = {x=rx, y=ry, type="room", subtype="side"}

		self:tunnel(rx, ry, cx, cy, 2 + i)
	end

	-- Always starts at 1, 1
	return self:makeStairsInside(lev, old_lev, self.spots)
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
