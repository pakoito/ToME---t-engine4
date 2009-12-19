require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(map, grid_list, data)
	engine.Generator.init(self, map)
	self.data = data
	self.data.tunnel_change = self.data.tunnel_change or 30
	self.data.tunnel_random = self.data.tunnel_random or 10
	self.data.tunnel_premature_end = self.data.tunnel_premature_end or 10
	self.grid_list = grid_list

	self.rooms = {}
	for i, file in ipairs(data.rooms) do
		table.insert(self.rooms, self:loadRoom(file))
	end

	self.room_map = {}
	for i = 0, self.map.w - 1 do
		self.room_map[i] = {}
		for j = 0, self.map.h - 1 do
			self.room_map[i][j] = {}
		end
	end
end

function _M:loadRoom(file)
	local f = loadfile("/data/rooms/"..file..".lua")
	local d = {}
	setfenv(f, d)
	local ret, err = f()
	if not ret and err then error(err) end

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

function _M:resolve(c)
	local res = self.data[c]
	if type(res) == "function" then
		return res()
	elseif type(res) == "table" then
		return res[rng.range(1, #res)]
	else
		return res
	end
end

function _M:roomAlloc(room, id)
	print("alloc", room.name)

	local tries = 100
	while tries > 0 do
		local ok = true
		local x, y = rng.range(1, self.map.w - 2 - room.w), rng.range(1, self.map.h - 2 - room.h)

		-- Do we stomp ?
		for i = 1, room.w do
			for j = 1, room.h do
				if self.room_map[i-1+x][j-1+y].room then ok = false break end
			end
			if not ok then break end
		end

		if ok then
			-- ok alloc it
			for i = 1, room.w do
				for j = 1, room.h do
					self.room_map[i-1+x][j-1+y].room = id
					local c = room[i][j]
					if c == '!' then
						self.room_map[i-1+x][j-1+y].can_open = true
						self.map(i-1+x, j-1+y, Map.TERRAIN, self.grid_list[self:resolve('#')])
					else
						self.map(i-1+x, j-1+y, Map.TERRAIN, self.grid_list[self:resolve(c)])
					end
				end
			end
			print("room allocated at", x, y,"with center",math.floor(x+(room.w-1)/2), math.floor(y+(room.h-1)/2))
			return { id=id, x=x, y=y, cx=math.floor(x+(room.w-1)/2), cy=math.floor(y+(room.h-1)/2), room=room }
		end
		tries = tries - 1
	end
	return false
end

function _M:randDir()
	local dirs = {4,6,8,2}
	local d = dir_to_coord[dirs[rng.range(1, #dirs)]]
	return d[1], d[2]
end

function _M:tunnelDir(x1, y1, x2, y2)
	local xdir = (x1 == x2) and 0 or ((x1 < x2) and 1 or -1)
	local ydir = (y1 == y2) and 0 or ((y1 < y2) and 1 or -1)
	if xdir ~= 0 and ydir ~= 0 then
		if rng.percent(50) then xdir = 0
		else ydir = 0
		end
	end
	return xdir, ydir
end

function _M:tunnel(x1, y1, x2, y2)
	local xdir, ydir = self:tunnelDir(x1, y1, x2, y2)
	print("tunneling from",x1, y1, "to", x2, y2, "initial dir", xdir, ydir)

	local startx, starty = x1, y1
	local tun = {}

	local tries = 2000
	while tries > 0 do
		if rng.percent(self.data.tunnel_change) then
			if rng.percent(self.data.tunnel_random) then
				xdir, ydir = self:randDir()
			else
				xdir, ydir = self:tunnelDir(x1, y1, x2, y2)
			end
		end

		local nx, ny = x1 + xdir, y1 + ydir
		while true do
			if self.map:isBound(nx, ny) and (self.room_map[nx][ny].room or not self.room_map[nx][ny].tunnel) then break end

			if rng.percent(self.data.tunnel_random) then
				xdir, ydir = self:randDir()
			else
				xdir, ydir = self:tunnelDir(x1, y1, x2, y2)
			end
			nx, ny = x1 + xdir, y1 + ydir
		end

		if self.room_map[nx][ny].room and not self.room_map[nx][ny].can_open then
		else
			for i = -1, 1 do for j = -1, 1 do
				if self.map:isBound(nx + i, ny + j) then
					self.room_map[nx + i][ny + j].can_open = false
				end
			end end

			tun[#tun+1] = {nx,ny}
		end
		x1, y1 = nx, ny

		if x1 == x2 and y1 == y2 then break end

		tries = tries - 1
	end

	for _, t in ipairs(tun) do
		local nx, ny = t[1], t[2]
--		self.room_map[nx][ny].tunnel = true
		self.map(nx, ny, Map.TERRAIN, self.grid_list[self:resolve("<")])
	end
end

function _M:generate()
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self.grid_list[self:resolve("#")])
	end end

	local nb_room = 10
	local rooms = {}
	while nb_room > 0 do
		local r = self:roomAlloc(self.rooms[rng.range(1, #self.rooms)], #rooms+1)
		if r then rooms[#rooms+1] = r end
		nb_room = nb_room - 1
	end

	-- Tunnels !
	print("Begin tunnel", #rooms, rooms[1])
	local tx, ty = rooms[1].cx, rooms[1].cy
	for i = 2, #rooms do
		self:tunnel(tx, ty, rooms[i].cx, rooms[i].cy)
		tx, ty = rooms[i].cx, rooms[i].cy
	end

	-- Always starts at 1, 1
	self.map(1, 1, Map.TERRAIN, self.up)
	return 1, 1
end
