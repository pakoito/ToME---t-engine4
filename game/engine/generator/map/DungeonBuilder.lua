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
end

function _M:generate()
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self.wall)
	end end



	-- Always starts at 1, 1
	self.map(1, 1, Map.TERRAIN, self.up)
	return 1, 1
end
