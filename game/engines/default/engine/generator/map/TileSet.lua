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
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

-- Deactivate too many prints
local print = function() end

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	self.data = data
	self.grid_list = zone.grid_list
	self.tiles, self.raw = {}, {}
	if type(data.tileset) == "string" then self:loadTiles(data.tileset)
	else for i, ts in ipairs(data.tileset) do self:loadTiles(ts) end end
	self.matching_tiles = {}

	self.block = self.raw.base
	self.cols = math.floor(self.map.w / self.block.w)
	self.rows = math.floor(self.map.h / self.block.h)
	self.room_map = {}
	for i = 0, self.cols do
		self.room_map[i] = {}
		for j = 0, self.rows do
			self.room_map[i][j] = false
		end
	end
end

function _M:findOpenings(t, c, i, j, mx, my)
	local d = self.raw
	if self:isOpening(c, d) and (i == 1 or i == mx or j == 1 or j == my) then
		if i == 1 and j == 1 then
--			table.insert(t.openings, {i, j, 7})
		elseif i == 1 and j == my then
--			table.insert(t.openings, {i, j, 1})
		elseif i == mx and j == my then
--			table.insert(t.openings, {i, j, 3})
		elseif i == mx and j == 1 then
--			table.insert(t.openings, {i, j, 9})
		elseif i == 1 then
			table.insert(t.openings, {i, j, 4})
		elseif i == mx then
			table.insert(t.openings, {i, j, 6})
		elseif j == 1 then
			table.insert(t.openings, {i, j, 8})
		elseif j == my then
			table.insert(t.openings, {i, j, 2})
		end
	end
end

function _M:loadTiles(tileset)
	local f, err = loadfile("/data/tilesets/"..tileset..".lua")
	if not f and err then error(err) end
	local d = self.raw
	setfenv(f, setmetatable(d, {__index=_G}))
	local ret, err = f()
	if not ret and err then error(err) end

	local tiles = self.tiles
	for idx, ts in ipairs(d.tiles) do
		local t = { id=#tiles+1, openings={}, type=ts.type }
		if not ts.no_random then tiles[#tiles+1] = t end
		if ts.define_as then tiles[ts.define_as] = t end

		-- X symmetric tile definition
		if ts.base and ts.symmetric and ts.symmetric == "x" then
			local ts = tiles[ts.base]
			local mx, my = #ts, #ts[1]
			for j = 1, my do for ri = 1, mx do
				local i = mx - ri + 1
				t[i] = t[i] or {}
				t[i][j] = ts[ri][j]
				self:findOpenings(t, t[i][j], i, j, mx, my)
			end end
			t.sizew, t.sizeh = mx / d.base.w, my / d.base.h

		-- Y symmetric tile definition
		elseif ts.base and ts.symmetric and ts.symmetric == "y" then
			local ts = tiles[ts.base]
			local mx, my = #ts, #ts[1]
			for rj = 1, my do for i = 1, mx do
				local j = my - rj + 1
				t[i] = t[i] or {}
				t[i][j] = ts[i][rj]
				self:findOpenings(t, t[i][j], i, j, mx, my)
			end end
			t.sizew, t.sizeh = mx / d.base.w, my / d.base.h

		-- 90degree rotation
		elseif ts.base and ts.rotation and ts.rotation == "90" then
			local ts = tiles[ts.base]
			local mx, my = #ts[1], #ts
			for j = 1, my do for ri = 1, mx do
				local i = mx - ri + 1
				t[i] = t[i] or {}
				t[i][j] = ts[j][ri]
				self:findOpenings(t, t[i][j], i, j, mx, my)
			end end
			t.sizew, t.sizeh = mx / d.base.w, my / d.base.h

		-- 180degree rotation
		elseif ts.base and ts.rotation and ts.rotation == "180" then
			local ts = tiles[ts.base]
			local mx, my = #ts, #ts[1]
			for rj = 1, my do for ri = 1, mx do
				local i = mx - ri + 1
				local j = my - rj + 1
				t[i] = t[i] or {}
				t[i][j] = ts[ri][rj]
				self:findOpenings(t, t[i][j], i, j, mx, my)
			end end
			t.sizew, t.sizeh = mx / d.base.w, my / d.base.h

		-- 270degree rotation
		elseif ts.base and ts.rotation and ts.rotation == "270" then
			local ts = tiles[ts.base]
			local mx, my = #ts[1], #ts
			for rj = 1, my do for i = 1, mx do
				local j = my - rj + 1
				t[i] = t[i] or {}
				t[i][j] = ts[rj][i]
				self:findOpenings(t, t[i][j], i, j, mx, my)
			end end
			t.sizew, t.sizeh = mx / d.base.w, my / d.base.h

		-- Normal tile definition
		else
			local my = #ts
			for j, line in ipairs(ts) do
				local i = 1
				local mx = line:len()
				for c in line:gmatch(".") do
					t[i] = t[i] or {}
					t[i][j] = c
					self:findOpenings(t, c, i, j, mx, my)

					i = i + 1
				end
				t.sizew, t.sizeh = mx / d.base.w, my / d.base.h
			end
		end
	end
end

function _M:roomAlloc(bx, by, bw, bh, rid)
	print("trying room at", bx,by,bw,bh)
	if bx + bw - 1 > self.cols or by + bh - 1 > self.rows then return false end
	if bx < 0 or by < 0 then return false end

	-- Do we stomp ?
	for i = bx, bx + bw - 1 do
		for j = by, by + bh - 1 do
			if self.room_map[i][j] then return false end
		end
	end

	-- ok alloc it
	for i = bx, bx + bw - 1 do
		for j = by, by + bh - 1 do
			self.room_map[i][j] = true
		end
	end
	print("room allocated at", bx,by,bw,bh)

	return true
end

function _M:isOpening(c, d)
	return d.is_opening(c)
end

function _M:matchTile(t1, t2)
	return self.raw.matcher(t1, t2)
end

function _M:findMatchingTiles(st, dir, type)
	-- If no type is given choose one
	if not type then
		type = "room"
		if rng.percent(self.data.tunnel_chance or 50) then type = "tunnel" end
	end

	if self.matching_tiles[st] and self.matching_tiles[st][dir] and self.matching_tiles[st][dir][type] then return self.matching_tiles[st][dir][type], type end

	local m = {}

	-- Examine all the size of the tile, and only the sides (for >1 base size tiles)
	-- This is extremely convoluted but the idea is simplistic:
	-- check each combination of position of tiles and find matching ones
	for stw = 1, st.sizew do for sth = 1, st.sizeh do if stw == 1 or stw == st.sizew or sth == 1 or sth == st.sizeh then
		local stwr, sthr = (stw-1) * self.block.w, (sth-1) * self.block.h

		-- Now look for matching tiles
		for _, dt in ipairs(self.tiles) do if dt.type == type then

			-- On all their subtile if they are big
			for dtw = 1, dt.sizew do for dth = 1, dt.sizeh do if dtw == 1 or dtw == dt.sizew or dth == 1 or dth == dt.sizeh then
				local dtwr, dthr = (dtw-1) * self.block.w, (dth-1) * self.block.h

				local ok = true
				local fullok = false

				-- Check each directions, for the correct side and see if the tile matches
				if dir == 8 and sth == 1 and dth == dt.sizeh then
					for i = 1, self.block.w do
						local ret, fo = self:matchTile(st[i+stwr][1], dt[i+dtwr][self.block.h*dt.sizeh])
						fullok = fullok or fo
						if not ret then ok = false end
					end
				elseif dir == 2 and sth == st.sizeh and dth == 1 then
					for i = 1, self.block.w do
						local ret, fo = self:matchTile(st[i+stwr][self.block.h*st.sizeh], dt[i+dtwr][1])
						fullok = fullok or fo
						if not ret then ok = false end
					end
				elseif dir == 4 and stw == 1 and dtw == dt.sizew then
					for j = 1, self.block.h do
						local ret, fo = self:matchTile(st[1][j+sthr], dt[self.block.w*dt.sizew][j+dthr])
						fullok = fullok or fo
						if not ret then ok = false end
					end
				elseif dir == 6 and stw == st.sizew and dtw == 1 then
					for j = 1, self.block.h do
						local ret, fo = self:matchTile(st[self.block.w*st.sizew][j+sthr], dt[1][j+dthr])
						fullok = fullok or fo
						if not ret then ok = false end
					end
				end

				-- if the tile matches, and there is a passageway then remember it
				if ok and fullok then
					m[#m+1] = {tile=dt, stw=stw-1, sth=sth-1, dtw=dtw-1, dth=dth-1}
					print("found matching tile in dir", dir, "from", st.id, stw, sth, "to", dt.id, dtw, dth)
					for j = 1, self.block.h * dt.sizeh do
						local s = ""
						for i = 1, self.block.w * dt.sizew do
							s = s..dt[i][j]
						end
						print(s)
					end
				end
			end end end
		end end
	end end end

	self.matching_tiles[st] = self.matching_tiles[st] or {}
	self.matching_tiles[st][dir] = self.matching_tiles[st][dir] or {}
	self.matching_tiles[st][dir][type] = m

	return m, type
end

function _M:buildTile(tile, bx, by, rid)
	local bw, bh = tile.sizew, tile.sizeh

	if not self:roomAlloc(bx, by, bw, bh, rid) then return false end

	print("building tile", tile.id, #tile, #tile[1])
	for j = 1, #tile[1] do
		for i = 1, #tile do
			if self.map.room_map[bx * self.block.w + i - 1] and self.map.room_map[bx * self.block.w + i - 1][by * self.block.h + j - 1] then
				self.map.room_map[bx * self.block.w + i - 1][by * self.block.h + j - 1].symbol = tile[i][j]
			end
		end
	end
	local opens = {}
	for i, o in ipairs(tile.openings) do
		print(" * opening in dir ", o[3], "::", o[1], o[2])
		local x, y = util.dirToCoord(o[3], o[1], o[2])
		local mts, type = self:findMatchingTiles(tile, o[3])
		-- if we found no match for the given type try the other one
		if #mts == 0 then mts, type = self:findMatchingTiles(tile, o[3], type == "room" and "tunnel" or "room") end

		if #mts > 0 then
			local mt = mts[rng.range(1, #mts)]
			opens[#opens+1] = {bx + x + mt.stw, by + y + mt.sth, tile=mt.tile}
			print("room at ",bx,by,"opens to",o[3],"::",bx + x, by + y)
		end
	end

	return opens
end

function _M:createMap()
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		local c = self.map.room_map[i][j].symbol
		if self.raw.filler then c = self.raw.filler(c, i, j, self.map.room_map, self.data) end
		self.map(i, j, Map.TERRAIN, self:resolve(c))
	end end
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
	error("Side stairs not supported by TileSet map generator")
end

function _M:placeStartTiles(tiles, process)
	for i, td in ipairs(tiles) do
		local tile = td.tile or rng.range(1, #self.tiles)
		local x, y = td.x or math.floor(self.cols / 2), td.y or math.floor(self.rows / 2)
		process[#process+1] = {x, y, tile=self.tiles[tile]}
	end
end

function _M:generate(lev, old_lev)
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self:resolve("#"))
	end end

	local process = {}
	local id = 1

	if not self.data.start_tiles then
		process[#process+1] = {math.floor(self.cols / 2), math.floor(self.rows / 2), tile=self.tiles[rng.range(1, #self.tiles)]}
	else
		self:placeStartTiles(self.data.start_tiles, process)
	end
	while #process > 0 do
		local b = table.remove(process)

		local opens = self:buildTile(b.tile, b[1], b[2], id)
		if opens then
			id = id + 1

			-- Add openings
			for i, o in ipairs(opens) do process[#process+1] = o end
		end
	end

	-- Fill the map with the real entities based on the map.room_map symbols
	self:createMap()

	-- Make stairs
	local spots = {}
	if self.data.edge_entrances then
		return self:makeStairsSides(lev, old_lev, self.data.edge_entrances, spots)
	else
		return self:makeStairsInside(lev, old_lev, spots)
	end
end
