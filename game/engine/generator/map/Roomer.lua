require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, grid_list, data)
	engine.Generator.init(self, zone, map)
	self.data = data
	self.data.tunnel_change = self.data.tunnel_change or 30
	self.data.tunnel_random = self.data.tunnel_random or 10
	self.data.door_chance = self.data.door_chance or 50
	self.data.lite_room_chance = self.data.lite_room_chance or 25
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

--- Make up a room
function _M:roomAlloc(room, id, lev, old_lev)
	if type(room) == 'function' then
		print("room generator", room, "is making a room")
		room = room(self, id, lev, old_lev)
	end
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
			local is_lit = rng.percent(self.data.lite_room_chance)

			-- ok alloc it using the default generator or a specific one
			if room.generator then
				room:generator(x, y, is_lit)
			else
				for i = 1, room.w do
					for j = 1, room.h do
						self.room_map[i-1+x][j-1+y].room = id
						local c = room[i][j]
						if c == '!' then
							self.room_map[i-1+x][j-1+y].room = nil
							self.room_map[i-1+x][j-1+y].can_open = true
							self.map(i-1+x, j-1+y, Map.TERRAIN, self.grid_list[self:resolve('#')])
						else
							self.map(i-1+x, j-1+y, Map.TERRAIN, self.grid_list[self:resolve(c)])
						end
						if is_lit then self.map.lites(i-1+x, j-1+y, true) end
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

--- Random tunnel dir
function _M:randDir()
	local dirs = {4,6,8,2}
	local d = dir_to_coord[dirs[rng.range(1, #dirs)]]
	return d[1], d[2]
end

--- Find the direction in which to tunnel
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

local mark_dirs = {
	[4] = {9,6,3},
	[6] = {7,4,1},
	[8] = {1,2,3},
	[2] = {7,8,9},
}
--- Marks a tunnel as a tunnel and the space behind it
function _M:markTunnel(x, y, xdir, ydir, id)
	x, y = x - xdir, y - ydir
	local dir = coord_to_dir[xdir][ydir]
	for i, d in ipairs(mark_dirs[dir]) do
		local xd, yd = dir_to_coord[d][1], dir_to_coord[d][2]
		if self.map:isBound(x+xd, y+yd) and not self.room_map[x+xd][y+yd].tunnel then self.room_map[x+xd][y+yd].tunnel = id print("mark tunnel", x+xd, y+yd , id) end
	end
	if not self.room_map[x][y].tunnel then self.room_map[x][y].tunnel = id print("mark tunnel", x, y , id) end
end

--- Tunnel from x1,y1 to x2,y2
function _M:tunnel(x1, y1, x2, y2, id)
	local xdir, ydir = self:tunnelDir(x1, y1, x2, y2)
	print("tunneling from",x1, y1, "to", x2, y2, "initial dir", xdir, ydir)

	local startx, starty = x1, y1
	local tun = {}

	local tries = 2000
	local no_move_tries = 0
	while tries > 0 do
		if rng.percent(self.data.tunnel_change) then
			if rng.percent(self.data.tunnel_random) then xdir, ydir = self:randDir()
			else xdir, ydir = self:tunnelDir(x1, y1, x2, y2)
			end
		end

		local nx, ny = x1 + xdir, y1 + ydir
		while true do
			if self.map:isBound(nx, ny) then break end

			if rng.percent(self.data.tunnel_random) then xdir, ydir = self:randDir()
			else xdir, ydir = self:tunnelDir(x1, y1, x2, y2)
			end
			nx, ny = x1 + xdir, y1 + ydir
		end
		print(feat, "try pos", nx, ny, "dir", coord_to_dir[xdir][ydir])

		if self.room_map[nx][ny].special then
			print(feat, "refuse special")
		elseif self.room_map[nx][ny].room then
			tun[#tun+1] = {nx,ny}
			x1, y1 = nx, ny
			print(feat, "accept room")
		elseif self.room_map[nx][ny].can_open ~= nil then
			if self.room_map[nx][ny].can_open then
				print(feat, "tunnel crossing can_open", nx,ny)
				for i = -1, 1 do for j = -1, 1 do if self.map:isBound(nx + i, ny + j) and self.room_map[nx + i][ny + j].can_open then
--					self.room_map[nx + i][ny + j].can_open = false
--					print(feat, "forbiding crossing at ", nx+i,ny+j)
				end end end
				tun[#tun+1] = {nx,ny,true}
				x1, y1 = nx, ny
				print(feat, "accept can_open")
			else
				print(feat, "reject can_open")
			end
		elseif self.room_map[nx][ny].tunnel then
			if self.room_map[nx][ny].tunnel ~= id or no_move_tries >= 15 then
				tun[#tun+1] = {nx,ny}
				x1, y1 = nx, ny
				print(feat, "accept tunnel", self.room_map[nx][ny].tunnel, id)
			else
				print(feat, "reject tunnel", self.room_map[nx][ny].tunnel, id)
			end
		else
			tun[#tun+1] = {nx,ny}
			x1, y1 = nx, ny
			print(feat, "accept normal")
		end

		if x1 == nx and y1 == ny then
			self:markTunnel(x1, y1, xdir, ydir, id)
			no_move_tries = 0
		else
			no_move_tries = no_move_tries + 1
		end

		if x1 == x2 and y1 == y2 then print(feat, "done") break end

		tries = tries - 1
	end

	for _, t in ipairs(tun) do
		local nx, ny = t[1], t[2]
		if t[3] and self.data.door and rng.percent(self.data.door_chance) then
			self.map(nx, ny, Map.TERRAIN, self.grid_list[self:resolve("door")])
		else
			self.map(nx, ny, Map.TERRAIN, self.grid_list[self:resolve('.')])
		end
	end
end

--- Create the stairs inside the level
function _M:makeStairsInside(lev, old_lev, spots)
	-- Put down stairs
	local dx, dy
	if lev < self.zone.max_level or self.data.force_last_stair then
		while true do
			dx, dy = rng.range(1, self.map.w - 1), rng.range(1, self.map.h - 1)
			if not self.map:checkEntity(dx, dy, Map.TERRAIN, "block_move") and not self.room_map[dx][dy].special then
				self.map(dx, dy, Map.TERRAIN, self.grid_list[self:resolve("down")])
				break
			end
		end
	end

	-- Put up stairs
	local ux, uy
	while true do
		ux, uy = rng.range(1, self.map.w - 1), rng.range(1, self.map.h - 1)
		if not self.map:checkEntity(ux, uy, Map.TERRAIN, "block_move") and not self.room_map[ux][uy].special then
			self.map(ux, uy, Map.TERRAIN, self.grid_list[self:resolve("up")])
			break
		end
	end

	return ux, uy, dx, dy, spots
end

--- Create the stairs on the sides
function _M:makeStairsSides(lev, old_lev, sides, rooms, spots)
	-- Put down stairs
	local dx, dy
	if lev < self.zone.max_level or self.data.force_last_stair then
		while true do
			if     sides[2] == 4 then dx, dy = 0, rng.range(1, self.map.h - 1)
			elseif sides[2] == 6 then dx, dy = self.map.w - 1, rng.range(1, self.map.h - 1)
			elseif sides[2] == 8 then dx, dy = rng.range(1, self.map.w - 1), 0
			elseif sides[2] == 2 then dx, dy = rng.range(1, self.map.w - 1), self.map.h - 1
			end

			if not self.room_map[dx][dy].special then
				local i = rng.range(1, #rooms)
				self:tunnel(dx, dy, rooms[i].cx, rooms[i].cy, rooms[i].id)
				self.map(dx, dy, Map.TERRAIN, self.grid_list[self:resolve("down")])
				break
			end
		end
	end

	-- Put up stairs
	local ux, uy
	while true do
		if     sides[1] == 4 then ux, uy = 0, rng.range(1, self.map.h - 1)
		elseif sides[1] == 6 then ux, uy = self.map.w - 1, rng.range(1, self.map.h - 1)
		elseif sides[1] == 8 then ux, uy = rng.range(1, self.map.w - 1), 0
		elseif sides[1] == 2 then ux, uy = rng.range(1, self.map.w - 1), self.map.h - 1
		end

		if not self.room_map[ux][uy].special then
			local i = rng.range(1, #rooms)
			self:tunnel(ux, uy, rooms[i].cx, rooms[i].cy, rooms[i].id)
			self.map(ux, uy, Map.TERRAIN, self.grid_list[self:resolve("up")])
			break
		end
	end

	return ux, uy, dx, dy, spots
end

--- Make rooms and connect them with tunnels
function _M:generate(lev, old_lev)
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self.grid_list[self:resolve("#")])
	end end

	local nb_room = self.data.nb_rooms or 10
	local rooms = {}
	while nb_room > 0 do
		local r = self:roomAlloc(self.rooms[rng.range(1, #self.rooms)], #rooms+1, lev, old_lev)
		if r then rooms[#rooms+1] = r end
		nb_room = nb_room - 1
	end

	-- Tunnels !
	if not self.data.no_tunnels then
		print("Begin tunnel", #rooms, rooms[1])
		local tx, ty = rooms[1].cx, rooms[1].cy
		for ii = 2, #rooms + 1 do
			local i = util.boundWrap(ii, 1, #rooms)
			self:tunnel(tx, ty, rooms[i].cx, rooms[i].cy, rooms[i].id)
			tx, ty = rooms[i].cx, rooms[i].cy
		end
	end

	-- Find out "interresting" spots
	local spots = {}
	for i, r in ipairs(rooms) do
		spots[#spots+1] = {x=rooms[i].cx, y=rooms[i].cy, type="room"}
	end

	if self.data.edge_entrances then
		return self:makeStairsSides(lev, old_lev, self.data.edge_entrances, rooms, spots)
	else
		return self:makeStairsInside(lev, old_lev, spots)
	end
end
