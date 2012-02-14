-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	self.data.tunnel_change = self.data.tunnel_change or 30
	self.data.tunnel_random = self.data.tunnel_random or 10
	self.data.door_chance = self.data.door_chance or 50
	self.data.lite_room_chance = self.data.lite_room_chance or 25
	self.grid_list = zone.grid_list

	RoomsLoader.init(self, data)
	self.possible_doors = {}
end

--- Random tunnel dir
function _M:randDir(sx, sy)
	local dirs = util.primaryDirs() --{4,6,8,2}
	return util.dirToCoord(dirs[rng.range(1, #dirs)], sx, sy)
end

--- Find the direction in which to tunnel
function _M:tunnelDir(x1, y1, x2, y2)
	-- HEX TODO ?
	local xdir = (x1 == x2) and 0 or ((x1 < x2) and 1 or -1)
	local ydir = (y1 == y2) and 0 or ((y1 < y2) and 1 or -1)
	if xdir ~= 0 and ydir ~= 0 then
		if rng.percent(50) then xdir = 0
		else ydir = 0
		end
	end
	return xdir, ydir
end

--- Marks a tunnel as a tunnel and the space behind it
function _M:markTunnel(x, y, xdir, ydir, id)
	-- Disable the many prints of tunnelling
	local print = function()end

	x, y = x - xdir, y - ydir
	local dir = util.coordToDir(xdir, ydir, x, y)
	local sides = util.dirSides(dir, x, y)
	local mark_dirs = {dir, sides.left, sides.right}
	for i, d in ipairs(mark_dirs) do
		local xd, yd = util.dirToCoord(d, x, y)
		if self.map:isBound(x+xd, y+yd) and not self.map.room_map[x+xd][y+yd].tunnel then self.map.room_map[x+xd][y+yd].tunnel = id print("mark tunnel", x+xd, y+yd , id) end
	end
	if not self.map.room_map[x][y].tunnel then self.map.room_map[x][y].tunnel = id print("mark tunnel", x, y , id) end
	self.map.room_map[x][y].real_tunnel = true
end

--- Can we create a door (will it lead anywhere)
function _M:canDoor(x, y)
	local open_spaces = {}
	for dir, coord in pairs(util.adjacentCoords(x, y)) do
		open_spaces[dir] = not self.map:checkEntity(coord[1], coord[2], Map.TERRAIN, "block_move")
	end

	-- Check the cardinal directions
	for i, dir in pairs(util.primaryDirs()) do
		local opposed_dir = util.opposedDir(dir, x, y)
		if open_spaces[dir] and open_spaces[opposed_dir] then
			local sides = util.dirSides(opposed_dir, x, y)
			-- HEX TODO: hex tiles should not use hard left/right, but this is hackish
			if util.isHex() then
				sides = table.clone(sides)
				sides.hard_left = nil
				sides.hard_right = nil
			end
			local blocked = true
			for _, check_dir in pairs(sides) do
				blocked = blocked and not open_spaces[check_dir]
			end
			if blocked then return true end
		end
	end
	return false
end

--- Tunnel from x1,y1 to x2,y2
function _M:tunnel(x1, y1, x2, y2, id)
	if x1 == x2 and y1 == y2 then return end
	-- Disable the many prints of tunnelling
	local print = function()end

	local xdir, ydir = self:tunnelDir(x1, y1, x2, y2)
--	print("tunneling from",x1, y1, "to", x2, y2, "initial dir", xdir, ydir)

	local startx, starty = x1, y1
	local tun = {}

	local tries = 2000
	local no_move_tries = 0
	while tries > 0 do
		if rng.percent(self.data.tunnel_change) then
			if rng.percent(self.data.tunnel_random) then xdir, ydir = self:randDir(x1, x2)
			else xdir, ydir = self:tunnelDir(x1, y1, x2, y2)
			end
		end

		local nx, ny = x1 + xdir, y1 + ydir
		while true do
			if self.map:isBound(nx, ny) then break end

			if rng.percent(self.data.tunnel_random) then xdir, ydir = self:randDir(nx, ny)
			else xdir, ydir = self:tunnelDir(x1, y1, x2, y2)
			end
			nx, ny = x1 + xdir, y1 + ydir
		end
		print(feat, "try pos", nx, ny, "dir", util.coordToDir(xdir, ydir, nx, ny))

		if self.map.room_map[nx][ny].special then
			print(feat, "refuse special")
		elseif self.map.room_map[nx][ny].room then
			tun[#tun+1] = {nx,ny,false,true}
			x1, y1 = nx, ny
			print(feat, "accept room")
		elseif self.map.room_map[nx][ny].can_open ~= nil then
			if self.map.room_map[nx][ny].can_open then
				print(feat, "tunnel crossing can_open", nx,ny)
				for _, coord in pairs(util.adjacentCoords(nx, ny)) do
					if self.map:isBound(coord[1], coord[2]) and self.map.room_map[coord[1]][coord[2]].can_open then
						self.map.room_map[coord[1]][coord[2]].can_open = false
						print(feat, "forbidding crossing at ", coord[1], coord[2])
					end
				end
				tun[#tun+1] = {nx,ny,true}
				x1, y1 = nx, ny
				print(feat, "accept can_open")
			else
				print(feat, "reject can_open")
			end
		elseif self.map.room_map[nx][ny].tunnel then
			if self.map.room_map[nx][ny].tunnel ~= id or no_move_tries >= 15 then
				tun[#tun+1] = {nx,ny}
				x1, y1 = nx, ny
				print(feat, "accept tunnel", self.map.room_map[nx][ny].tunnel, id)
			else
				print(feat, "reject tunnel", self.map.room_map[nx][ny].tunnel, id)
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

	local doors = {}
	for _, t in ipairs(tun) do
		local nx, ny = t[1], t[2]
		if t[3] and self.data.door then self.possible_doors[#self.possible_doors+1] = t end
		if not t[4] then
			self.map(nx, ny, Map.TERRAIN, self:resolve('.'))
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

			if not self.map.room_map[dx][dy].special then
				local i = rng.range(1, #rooms)
				self:tunnel(dx, dy, rooms[i].cx, rooms[i].cy, rooms[i].id)
				self.map(dx, dy, Map.TERRAIN, self:resolve("down"))
				self.map.room_map[dx][dy].special = "exit"
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

		if not self.map.room_map[ux][uy].special then
			local i = rng.range(1, #rooms)
			self:tunnel(ux, uy, rooms[i].cx, rooms[i].cy, rooms[i].id)
			self.map(ux, uy, Map.TERRAIN, self:resolve("up"))
			self.map.room_map[ux][uy].special = "exit"
			break
		end
	end

	return ux, uy, dx, dy, spots
end

--- Make rooms and connect them with tunnels
function _M:generate(lev, old_lev)
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self:resolve("#"))
	end end

	local spots = {}
	self.spots = spots

	local nb_room = util.getval(self.data.nb_rooms or 10)
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

	-- Forced tunnels
	if self.data.force_tunnels then
		for _, t in ipairs(self.data.force_tunnels) do
			local sx, sy, ex, ey
			if type(t[1]) == "string" then
				local i = rng.range(1, #rooms)
				sx, sy = rooms[i].cx, rooms[i].cy
			else
				sx, sy = t[1][1], t[1][2]
			end
			if type(t[2]) == "string" then
				local i = rng.range(1, #rooms)
				ex, ey = rooms[i].cx, rooms[i].cy
			else
				ex, ey = t[2][1], t[2][2]
			end
			self:tunnel(sx, sy, ex, ey, t.id)
		end
	end

	-- Put doors where possible
	for _, t in ipairs(self.possible_doors) do
		local nx, ny = t[1], t[2]
		if rng.percent(self.data.door_chance) and self:canDoor(nx, ny) then
			self.map(nx, ny, Map.TERRAIN, self:resolve("door"))
		end
	end

	-- Find out "interesting" spots
	for i, r in ipairs(rooms) do
		spots[#spots+1] = {x=rooms[i].cx, y=rooms[i].cy, type="room", subtype=rooms[i].room.name}
	end

	if self.data.edge_entrances then
		return self:makeStairsSides(lev, old_lev, self.data.edge_entrances, rooms, spots)
	else
		return self:makeStairsInside(lev, old_lev, spots)
	end
end
