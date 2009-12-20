require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, grid_list, data)
	engine.Generator.init(self, zone, map)
	self.data = data
	self.grid_list = grid_list
	self.tiles, self.raw = self:loadTiles(data.tileset)
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

function _M:loadTiles(tileset)
	local f = loadfile("/data/tilesets/"..tileset..".lua")
	local d = {}
	setfenv(f, d)
	local ret, err = f()
	if not ret and err then error(err) end

	local tiles = {}
	for idx, ts in ipairs(d.tiles) do
		local t = { id=idx, openings={} }
		tiles[idx] = t
		for j, line in ipairs(ts) do
			local i = 1
			for c in line:gmatch(".") do
				t[i] = t[i] or {}
				t[i][j] = c

				-- Find edge openings
				local mx, my = line:len(), #ts
				if c == '.' and (i == 1 or i == mx or j == 1 or j == my) then
					if i == 1 and j == 1 then
						table.insert(t.openings, {i, j, 7})
					elseif i == 1 and j == my then
						table.insert(t.openings, {i, j, 1})
					elseif i == mx and j == my then
						table.insert(t.openings, {i, j, 3})
					elseif i == mx and j == 1 then
						table.insert(t.openings, {i, j, 9})
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

				i = i + 1
			end
		end
	end

	return tiles, d
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

function _M:matchTile(t1, t2)
	return self.raw.matcher(t1, t2)
end

function _M:findMatchingTiles(st, dir)
	if self.matching_tiles[st] and self.matching_tiles[st][dir] then return self.matching_tiles[st][dir] end

	local m = {}

	for _, dt in ipairs(self.tiles) do
		local ok = true
		if dir == 8 then
			for i = 1, self.block.w do
				if not self:matchTile(st[i][1], dt[i][self.block.h]) then ok = false end
			end
		elseif dir == 2 then
			for i = 1, self.block.w do
				if not self:matchTile(st[i][self.block.h], dt[i][1]) then ok = false end
			end
		elseif dir == 4 then
			for j = 1, self.block.h do
				if not self:matchTile(st[1][j], dt[#dt][j]) then ok = false end
			end
		elseif dir == 6 then
			for j = 1, self.block.h do
				if not self:matchTile(st[#dt][j], dt[1][j]) then ok = false end
			end
		end
		if ok then
			m[#m+1] = dt
			print("found matching tile in dir", dir, "from", st.id, "to", dt.id)
		end
	end

	self.matching_tiles[st] = self.matching_tiles[st] or {}
	self.matching_tiles[st][dir] = m

	return m
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

function _M:buildTile(tile, bx, by, rid)
	local bw, bh = 1, 1

	if not self:roomAlloc(bx, by, bw, bh, rid) then return false end

	print("building tile", tile.id, #tile, #tile[1])
	for i = 1, #tile do
		for j = 1, #tile[1] do
			self.map(bx * self.block.w + i - 1, by * self.block.h + j - 1, Map.TERRAIN, self.grid_list[self:resolve(tile[i][j])])
		end
	end
	local opens = {}
	for i, o in ipairs(tile.openings) do
		local coord = dir_to_coord[o[3]]
		local mts = self:findMatchingTiles(tile, o[3])

		if #mts > 0 then
			opens[#opens+1] = {bx + coord[1], by + coord[2], tile=mts[rng.range(1, #mts)]}
			print("room at ",bx,by,"opens to",o[3],"::",bx + coord[1], by + coord[2])
		end
	end

	return opens
end

function _M:generate()
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self.grid_list[self:resolve("#")])
	end end

	local first = true
	local process = {}
	local id = 1
	process[#process+1] = {math.floor(self.cols / 2), math.floor(self.rows / 2), tile=self.tiles[2 or rng.range(1, #self.tiles)]}
	while #process > 0 do
		local b = table.remove(process)
		local type = "room"
		if not first and rng.percent(70) then type = "tunnel" end
		first = false

		local opens = self:buildTile(b.tile, b[1], b[2], id)
		if opens then
			id = id + 1

			-- Add openings
			for i, o in ipairs(opens) do process[#process+1] = o end
		end
	end

	-- Always starts at 1, 1
	self.map(1, 1, Map.TERRAIN, self.up)
	return 1, 1
end
