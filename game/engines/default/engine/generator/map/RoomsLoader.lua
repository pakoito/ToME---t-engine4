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

function _M:loadRoom(file)
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

	return t
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
	local is_lit = rng.percent(self.data.lite_room_chance)

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
function _M:roomAlloc(room, id, lev, old_lev)
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

		if ok then
			local res = self:roomPlace(room, id, x, y)
			if res then return res end
		end
		tries = tries - 1
	end
	return false
end
