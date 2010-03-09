require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	local grid_list = zone.grid_list
	self.floor = grid_list[data.floor]
	self.up = grid_list[data.up]
end

function _M:generate()
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self.floor)
	end end
	-- Always starts at 1, 1
	self.map(1, 1, Map.TERRAIN, self.up)
	return 1, 1
end
