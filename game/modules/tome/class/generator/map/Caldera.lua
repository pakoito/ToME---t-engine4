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
require "engine.generator.map.Roomer"
module(..., package.seeall, class.inherit(engine.generator.map.Roomer))

function _M:init(zone, map, level, data)
	engine.generator.map.Roomer.init(self, zone, map, level, data)
	self.spots = {}
	self.data = data
	self.grid_list = zone.grid_list

	data.trees_noise = data.trees_noise or "fbm_perlin"
	data.trees_zoom = data.trees_zoom or 5
	data.trees_max_percent = data.trees_max_percent or 50
	data.trees_sqrt_percent = data.trees_sqrt_percent or 30
	data.trees_hurst = data.trees_hurst or nil
	data.trees_lacunarity = data.trees_lacunarity or nil
	data.trees_octave = data.trees_octave or 4
end

function _M:generate(lev, old_lev)
	local data = self.data

	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self:resolve("mountain"))
	end end

	local cx, cy = math.floor(self.map.w / 2), math.floor(self.map.h / 2)
	local rg = math.floor(self.map.w / 2)
	local rl = math.floor(self.map.w / 4)

	self:makePod(cx, cy, rg, "grasscaldera", {
		base_breakpoint = data.base_breakpoint or 0.7,
		noise = data.noise or "fbm_perlin",
		zoom = data.zoom or 5,
		hurst = data.hurst or nil,
		lacunarity = data.lacunarity or nil,
		octave = data.octave or 4,
	}, "grass", "mountain")

	local noise = core.noise.new(2, data.trees_hurst, data.trees_lacunarity)
	for i = 1, self.map.w do
		for j = 1, self.map.h do
			if self.map:checkEntity(i, j, Map.TERRAIN, "grow") then
				local v = math.floor((noise[data.trees_noise](noise, data.trees_zoom * i / self.map.w, data.trees_zoom * j / self.map.h, data.trees_octave) / 2 + 0.5) * data.trees_max_percent)
				if (v >= data.trees_sqrt_percent and rng.percent(v)) or (v < data.trees_sqrt_percent and rng.percent(math.sqrt(v))) then
					self.map(i-1, j-1, Map.TERRAIN, self:resolve("tree"))
				end
			end
		end
	end

	self:makePod(cx, cy, rl, "grasscaldera", {
		base_breakpoint = data.base_breakpoint or 0.3,
		noise = data.noise or "fbm_perlin",
		zoom = data.zoom or 5,
		hurst = data.hurst or nil,
		lacunarity = data.lacunarity or nil,
		octave = data.octave or 4,
	}, "water", "grass")

	local sx, sy, ex, ey = 1, 1, 1, 1

	local sl = {}
	for i = 1, self.map.w -2 do
		for j = 1, self.map.h - 2 do
			if not self.map:checkEntity(i, j, Map.TERRAIN, "block_move") then sl[#sl+1] = {x=i, y=j} end
		end
		if #sl > 0 then break end
	end
	if #sl > 0 then
		local s = rng.table(sl)
		sx, sy = s.x, s.y
	end

	local el = {}
	for i = self.map.w -2, 1, -1 do
		for j = 1, self.map.h - 2 do
			if not self.map:checkEntity(i, j, Map.TERRAIN, "block_move") then el[#el+1] = {x=i, y=j} end
		end
		if #el > 0 then break end
	end
	if #el > 0 then
		local s = rng.table(el)
		ex, ey = s.x, s.y
	end

	self.map(sx, sy, Map.TERRAIN, self:resolve("up"))
	self.map(ex, ey, Map.TERRAIN, self:resolve("down"))

	-- Make stairs
	return sx, sy, ex, ey, self.spots
end
