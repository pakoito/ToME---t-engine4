require "engine.class"
require "engine.MapGenerator"
module(..., package.seeall, class.inherit(engine.MapGenerator))

function _M:init(map, splitzone, floor, wall)
	engine.MapGenerator.init(self, map)
	self.smallest = 100000
	self.tree = {}
	self.splitzone = splitzone
	self.floor, self.wall = floor, wall
end

function _M:split(x, y, w, h)
	local x1, y1, w1, h1
	local x2, y2, w2, h2
	local split, dir
	if rng.chance(2) then
		split = rng.range(w * self.splitzone[1], w * self.splitzone[2])
		x1, y1, w1, h1 = x, y, split, h
		x2, y2, w2, h2 = x + split, y, w - split, h
	else
		split = rng.range(h * self.splitzone[1], h * self.splitzone[2])
		x1, y1, w1, h1 = x, y, w, split
		x2, y2, w2, h2 = x, y + split, w, h - split
--		print(x1, y1, w1, h1)
--		print(x2, y2, w2, h2)
	end
	return {x1, y1, w1, h1}, {x2, y2, w2, h2}
end

function _M:fill(t)
	for i = t[1], t[1] + t[3] - 1 do
		for j = t[2], t[2] + t[4] - 1 do
			if i == t[1] or i == t[1] + t[3] - 1 or j == t[2] or j == t[2] + t[4] - 1 then
				self.map(i, j, engine.Map.TERRAIN, self.wall)
			else
				self.map(i, j, engine.Map.TERRAIN, self.floor)
			end
		end
	end
end

function _M:roomSize(t)
	return t[3] * t[4]
end

function _M:generate()
	local process = { {0, 0, self.map.w, self.map.h} }
	local rooms = {}
	while #process > 0 do
		local baser = table.remove(process, 1)

		local r1, r2 = self:split(unpack(baser))

		if self:roomSize(r1) <= 40 or self:roomSize(r2) <= 40 or r1[3] < 6 or r1[4] < 6 or r2[3] < 6 or r2[4] < 6 then
			table.insert(rooms, r1)
			table.insert(rooms, r2)
		else
			table.insert(process, r1)
			table.insert(process, r2)
		end
	end

	for i, r in ipairs(rooms) do
		self:fill(r)
	end
end
