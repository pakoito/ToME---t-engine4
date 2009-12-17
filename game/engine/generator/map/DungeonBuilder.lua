require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(map, grid_list, data)
	engine.Generator.init(self, map)
	self.floor = grid_list[data.floor]
	self.wall = grid_list[data.wall]
	self.up = grid_list[data.up]
	self.down = grid_list[data.down]

	self.block = {w=11, h=11}
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

function _M:roomAlloc(bx, by, bw, bh, rid)
	print("trying room at", bx,by,bw,bh)
	if bx + bw - 1 > self.cols or by + bh - 1 > self.rows then return false end

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

function _M:buildSimpleRoom(bx, by, rid)
	local bw, bh = rng.range(1, 3), rng.range(1, 3)

	if not self:roomAlloc(bx, by, bw, bh, rid) then return false end

	for i = bx * self.block.w + 1, (bx + bw - 1) * self.block.w - 2 do
		for j = by * self.block.h + 1, (by + bh - 1) * self.block.h - 2 do
			self.map(i, j, Map.TERRAIN, self.floor)
		end
	end

	return true
end

function _M:generate()
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self.wall)
	end end

	local nb_room = 10
	while nb_room > 0 do
		local bx, by = rng.range(0, self.cols), rng.range(0, self.rows)
		if self:buildSimpleRoom(bx, by, nb_room) then
			nb_room = nb_room - 1
		end
	end

	-- Always starts at 1, 1
	self.map(1, 1, Map.TERRAIN, self.up)
	return 1, 1
end
