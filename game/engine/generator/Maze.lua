require "engine.class"
local Map = require "engine.Map"
require "engine.MapGenerator"
module(..., package.seeall, class.inherit(engine.MapGenerator))

function _M:init(map, floor, wall, up, down)
	engine.MapGenerator.init(self, map)
	self.floor, self.wall, self.up, self.down = floor, wall, up, down
end

function _M:generate()
	local backentity = engine.Entity.new{display='*', color_r=128, color_g=128, color_n=128}

	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self.wall)
	end end

	local xpos, ypos = 1, 1
	local moves = {{xpos,ypos}}
	while #moves > 0 do
		local dir = {}
		if self.map(xpos+2, ypos, Map.TERRAIN) == self.wall and xpos+2>0 and xpos+2<self.map.w-1 then
			dir[#dir+1] = 6
		end
		if self.map(xpos-2, ypos, Map.TERRAIN) == self.wall and xpos-2>0 and xpos-2<self.map.w-1 then
			dir[#dir+1] = 4
		end
		if self.map(xpos, ypos-2, Map.TERRAIN) == self.wall and ypos-2>0 and ypos-2<self.map.h-1 then
			dir[#dir+1] = 8
		end
		if self.map(xpos, ypos+2, Map.TERRAIN) == self.wall and ypos+2>0 and ypos+2<self.map.h-1 then
			dir[#dir+1] = 2
		end

		if #dir > 0 then
			local d = dir[rng.range(1, #dir)]
			if d == 4 then
				self.map(xpos-2, ypos, Map.TERRAIN, self.floor)
				self.map(xpos-1, ypos, Map.TERRAIN, self.floor)
				xpos = xpos - 2
			elseif d == 6 then
				self.map(xpos+2, ypos, Map.TERRAIN, self.floor)
				self.map(xpos+1, ypos, Map.TERRAIN, self.floor)
				xpos = xpos + 2
			elseif d == 8 then
				self.map(xpos, ypos-2, Map.TERRAIN, self.floor)
				self.map(xpos, ypos-1, Map.TERRAIN, self.floor)
				ypos = ypos - 2
			elseif d == 2 then
				self.map(xpos, ypos+2, Map.TERRAIN, self.floor)
				self.map(xpos, ypos+1, Map.TERRAIN, self.floor)
				ypos = ypos + 2
			end
			table.insert(moves, {xpos, ypos})
		else
			local back = table.remove(moves)
			xpos = back[1]
			ypos = back[2]
		end
	end
	-- Always starts at 1, 1
	self.map(1, 1, Map.TERRAIN, self.up)
	self.map(math.floor(self.map.w/2)*2-3, math.floor(self.map.h/2)*2-3, Map.TERRAIN, self.up)
	return 1, 1
end
