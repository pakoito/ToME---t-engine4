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
require "engine.Generator"
local RoomsLoader = require "engine.generator.map.RoomsLoader"
module(..., package.seeall, class.inherit(engine.Generator, RoomsLoader))

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	self.data = data
	self.grid_list = self.zone.grid_list
	self.noise = data.noise or "fbm_perlin"
	self.zoom = data.zoom or 5
	self.max_percent = data.max_percent or 80
	self.sqrt_percent = data.sqrt_percent or 30
	self.hurst = data.hurst or nil
	self.lacunarity = data.lacunarity or nil
	self.octave = data.octave or 4
	self.do_ponds = data.do_ponds
	if self.do_ponds then
		self.do_ponds.zoom = self.do_ponds.zoom or 5
		self.do_ponds.octave = self.do_ponds.octave or 5
		self.do_ponds.hurst = self.do_ponds.hurst or nil
		self.do_ponds.lacunarity = self.do_ponds.lacunarity or nil
	end

	RoomsLoader.init(self, data)
end

function _M:addPond(x, y, spots)
	local noise = core.noise.new(2, self.do_ponds.size.w, self.do_ponds.size.h)
	local nmap = {}
	local lowest = {v=100, x=nil, y=nil}
	for i = 1, self.do_ponds.size.w do
		nmap[i] = {}
		for j = 1, self.do_ponds.size.h do
			nmap[i][j] = noise:fbm_simplex(self.do_ponds.zoom * i / self.do_ponds.size.w, self.do_ponds.zoom * j / self.do_ponds.size.h, self.do_ponds.octave)
			if nmap[i][j] < lowest.v then lowest.v = nmap[i][j]; lowest.x = i; lowest.y = j end
		end
	end
--	print("Lowest pond point", lowest.x, lowest.y," ::", lowest.v)

	local quadrant = function(i, j)
		local highest = {v=-100, x=nil, y=nil}
		local l = line.new(lowest.x, lowest.y, i, j)
		local lx, ly = l()
		while lx do
--			print(lx, ly, nmap[lx][ly])
			if nmap[lx][ly] > highest.v then highest.v = nmap[lx][ly]; highest.x = lx; highest.y = ly end
			lx, ly = l()
		end
--		print("Highest pond point", highest.x, highest.y," ::", highest.v)
		local split = (highest.v + lowest.v)

		local l = line.new(lowest.x, lowest.y, i, j)
		local lx, ly = l()
		while lx do
			local stop = true
			for _ = 1, #self.do_ponds.pond do
				if nmap[lx][ly] < split * self.do_ponds.pond[_][1] then
					self.map(lx-1+x, ly-1+y, Map.TERRAIN, self:resolve(self.do_ponds.pond[_][2], self.grid_list, true))
					stop = false
					break
				end
			end
			if stop then break end
			lx, ly = l()
		end
	end

	for i = 1, self.do_ponds.size.w do
		quadrant(i, 1)
		quadrant(i, self.do_ponds.size.h)
	end
	for i = 1, self.do_ponds.size.h do
		quadrant(1, i)
		quadrant(self.do_ponds.size.w, i)
	end

	spots[#spots+1] = {x=x, y=y, type="pond", subtype="pond"}
end

function _M:generate(lev, old_lev)
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self:resolve("floor"))
	end end

	-- make the noise
	local noise = core.noise.new(2, self.hurst, self.lacunarity)
	for i = 1, self.map.w do
		for j = 1, self.map.h do
			local v = math.floor((noise[self.noise](noise, self.zoom * i / self.map.w, self.zoom * j / self.map.h, self.octave) / 2 + 0.5) * self.max_percent)
			if (v >= self.sqrt_percent and rng.percent(v)) or (v < self.sqrt_percent and rng.percent(math.sqrt(v))) then
				self.map(i-1, j-1, Map.TERRAIN, self:resolve("wall"))
			else
				self.map(i-1, j-1, Map.TERRAIN, self:resolve("floor"))
			end
		end
	end

	local spots = {}
	self.spots = spots

	if self.do_ponds then
		for i = 1, rng.range(self.do_ponds.nb[1], self.do_ponds.nb[2]) do
			self:addPond(rng.range(self.do_ponds.size.w, self.map.w - self.do_ponds.size.w), rng.range(self.do_ponds.size.h, self.map.h - self.do_ponds.size.h), spots)
		end
	end

	local nb_room = util.getval(self.data.nb_rooms or 0)
	local rooms = {}
	while nb_room > 0 do
		local rroom
		while true do
			rroom = self.rooms[rng.range(1, #self.rooms)]
			if type(rroom) == "table" and rroom.chance_room then
				if rng.percent(rroom.chance_room) then rroom = rroom[1] break end
			else
				break
			end
		end

		local r = self:roomAlloc(rroom, #rooms+1, lev, old_lev)
		if r then rooms[#rooms+1] = r end
		nb_room = nb_room - 1
	end

	local ux, uy, dx, dy
	if self.data.edge_entrances then
		ux, uy, dx, dy, spots = self:makeStairsSides(lev, old_lev, self.data.edge_entrances, spots)
	else
		ux, uy, dx, dy, spots = self:makeStairsInside(lev, old_lev, spots)
	end

	return ux, uy, dx, dy, spots
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

--- Create the stairs on the sides
function _M:makeStairsSides(lev, old_lev, sides, spots)
	-- Put down stairs
	local dx, dy
	if lev < self.zone.max_level or self.data.force_last_stair then
		while true do
			if     sides[2] == 4 then dx, dy = 0, rng.range(0, self.map.h - 1)
			elseif sides[2] == 6 then dx, dy = self.map.w - 1, rng.range(0, self.map.h - 1)
			elseif sides[2] == 8 then dx, dy = rng.range(0, self.map.w - 1), 0
			elseif sides[2] == 2 then dx, dy = rng.range(0, self.map.w - 1), self.map.h - 1
			end

			if not self.map.room_map[dx][dy].special then
				self.map(dx, dy, Map.TERRAIN, self:resolve("down"))
				self.map.room_map[dx][dy].special = "exit"
				break
			end
		end
	end

	-- Put up stairs
	local ux, uy
	while true do
		if     sides[1] == 4 then ux, uy = 0, rng.range(0, self.map.h - 1)
		elseif sides[1] == 6 then ux, uy = self.map.w - 1, rng.range(0, self.map.h - 1)
		elseif sides[1] == 8 then ux, uy = rng.range(0, self.map.w - 1), 0
		elseif sides[1] == 2 then ux, uy = rng.range(0, self.map.w - 1), self.map.h - 1
		end

		if not self.map.room_map[ux][uy].special then
			self.map(ux, uy, Map.TERRAIN, self:resolve("up"))
			self.map.room_map[ux][uy].special = "exit"
			break
		end
	end

	return ux, uy, dx, dy, spots
end
