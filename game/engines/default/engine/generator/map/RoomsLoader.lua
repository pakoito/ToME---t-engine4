-- TE4 - T-Engine 4
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

--- Generator interface that can use rooms
module(..., package.seeall, class.make)

function _M:init(data)
	self.rooms = {}

	if not data.rooms then return end

	for i, file in ipairs(data.rooms) do
		if type(file) == "table" then
			table.insert(self.rooms, {self:loadRoom(file[1]), chance_room=file[2]})
		else
			table.insert(self.rooms, self:loadRoom(file))
		end
	end
end

local rooms_cache = {}

function _M:loadRoom(file)
	if rooms_cache[file] then return rooms_cache[file] end

	local f, err = loadfile("/data/rooms/"..file..".lua")
	if not f and err then error(err) end
	setfenv(f, setmetatable({
		Map = require("engine.Map"),
	}, {__index=_G}))
	local ret, err = f()
	if not ret and err then error(err) end

	-- We got a room generator function, save it for later
	if type(ret) == "function" then
		print("loaded room generator",file,ret)
		rooms_cache[file] = ret
		return ret
	end

	-- Init the room with name and size
	local t = { name=file, w=ret[1]:len(), h=#ret }

	-- Read the room map
	for j, line in ipairs(ret) do
		local i = 1
		for c in line:gmatch(".") do
			t[i] = t[i] or {}
			t[i][j] = c
			i = i + 1
		end
	end
	print("loaded room",file,t.w,t.h)

	rooms_cache[file] = t
	return t
end

--- Easy way to make an irregular shapped room
function _M:makePod(x, y, radius, room_id, data, floor, wall)
	self.map(x, y, Map.TERRAIN, self:resolve(floor or '.'))
	self.map.room_map[x][y].room = room_id

	local lowest = {x=x, y=y}

	local noise = core.noise.new(1, data.hurst, data.lacunarity)

	local idx = 0
	local quadrant = function(i, j)
		local breakdist = radius
		local n = noise[data.noise](noise, data.zoom * idx / (radius * 4), data.octave)
		n = (n + 1) / 2
		breakdist = data.base_breakpoint * breakdist + ((1 - data.base_breakpoint) * breakdist * n)
		idx = idx + 1

		local l = line.new(lowest.x, lowest.y, i, j)
		local lx, ly = l()
		while lx do
			if core.fov.distance(lowest.x, lowest.y, lx, ly) >= breakdist then break end
			if self.map:isBound(lx, ly) then
				self.map(lx, ly, Map.TERRAIN, self:resolve(floor or '.'))
				self.map.room_map[lx][ly].room = room_id
			end
			lx, ly = l()
		end
	end
	local idx = 0
	for i = -radius + x, radius + x do
		quadrant(i, -radius + y)
	end
	for i = -radius + y, radius + y do
		quadrant(radius + x, i)
	end
	for i = -radius + x, radius + x do
		quadrant(i, radius + y)
	end
	for i = -radius + y, radius + y do
		quadrant(-radius + x, i)
	end

	for i = -radius + x, radius + x do for j = -radius + y, radius + y do
		local g1 = self.map.room_map[i-1] and self.map.room_map[i-1][j+1] and self.map.room_map[i-1][j+1].room == room_id
		local g2 = self.map.room_map[i] and self.map.room_map[i][j+1] and self.map.room_map[i][j+1].room == room_id
		local g3 = self.map.room_map[i+1] and self.map.room_map[i+1][j+1] and self.map.room_map[i+1][j+1].room == room_id
		local g4 = self.map.room_map[i-1] and self.map.room_map[i-1][j] and self.map.room_map[i-1][j].room == room_id
		local g6 = self.map.room_map[i+1] and self.map.room_map[i+1][j] and self.map.room_map[i+1][j].room == room_id
		local g7 = self.map.room_map[i-1] and self.map.room_map[i-1][j-1] and self.map.room_map[i-1][j-1].room == room_id
		local g8 = self.map.room_map[i] and self.map.room_map[i][j-1] and self.map.room_map[i][j-1].room == room_id
		local g9 = self.map.room_map[i+1] and self.map.room_map[i+1][j-1] and self.map.room_map[i+1][j-1].room == room_id

		if     not g8 and not g4 and not g6 and g2 then self.map(i, j, Map.TERRAIN, self:resolve(wall or '#')) self.map.room_map[i][j].room = nil
		elseif not g2 and not g4 and not g6 and g8 then self.map(i, j, Map.TERRAIN, self:resolve(wall or '#')) self.map.room_map[i][j].room = nil
		elseif not g6 and not g2 and not g8 and g4 then self.map(i, j, Map.TERRAIN, self:resolve(wall or '#')) self.map.room_map[i][j].room = nil
		elseif not g4 and not g2 and not g8 and g6 then self.map(i, j, Map.TERRAIN, self:resolve(wall or '#')) self.map.room_map[i][j].room = nil
		end
	end end
end


--- Generates a room
function _M:roomGen(room, id, lev, old_lev)
	if type(room) == 'function' then
		print("room generator", room, "is making a room")
		room = room(self, id, lev, old_lev)
	end
	print("alloc", room.name)

	-- Sanity check
	if self.map.w - 2 - room.w < 2 or self.map.h - 2 - room.h < 2 then return false end

	return room
end

--- Place a room
function _M:roomPlace(room, id, x, y)
	local is_lit = rng.percent(self.data.lite_room_chance or 100)

	-- ok alloc it using the default generator or a specific one
	local cx, cy
	if room.generator then
		cx, cy = room:generator(x, y, is_lit)
	else
		for i = 1, room.w do
			for j = 1, room.h do
				self.map.room_map[i-1+x][j-1+y].room = id
				local c = room[i][j]
				if c == '!' then
					self.map.room_map[i-1+x][j-1+y].room = nil
					self.map.room_map[i-1+x][j-1+y].can_open = true
					self.map(i-1+x, j-1+y, Map.TERRAIN, self:resolve('#'))
				else
					self.map(i-1+x, j-1+y, Map.TERRAIN, self:resolve(c))
				end
				if is_lit then self.map.lites(i-1+x, j-1+y, true) end
			end
		end
	end
	print("room allocated at", x, y,"with center",math.floor(x+(room.w-1)/2), math.floor(y+(room.h-1)/2))
	cx = cx or math.floor(x+(room.w-1)/2)
	cy = cy or math.floor(y+(room.h-1)/2)
	return { id=id, x=x, y=y, cx=cx, cy=cy, room=room }
end

--- Make up a room
function _M:roomAlloc(room, id, lev, old_lev, add_check)
	room = self:roomGen(room, id, lev, old_lev)
	if not room then return end

	local tries = 100
	while tries > 0 do
		local ok = true
		local x, y = rng.range(1, self.map.w - 2 - room.w), rng.range(1, self.map.h - 2 - room.h)

		-- Do we stomp ?
		for i = 1, room.w do
			for j = 1, room.h do
				if self.map.room_map[i-1+x][j-1+y].room then ok = false break end
			end
			if not ok then break end
		end

		if ok and (not add_check or add_check(room, x, y)) then
			local res = self:roomPlace(room, id, x, y)
			if res then return res end
		end
		tries = tries - 1
	end
	return false
end
