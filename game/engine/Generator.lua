require "engine.class"
module(..., package.seeall, class.make)

function _M:init(zone, map, level)
	self.zone = zone
	self.map = map
	self.level = level

	-- Setup the map's room-map
	if not map.room_map then
		map.room_map = {}
		for i = 0, map.w - 1 do
			map.room_map[i] = {}
			for j = 0, map.h - 1 do
				map.room_map[i][j] = {}
			end
		end
	end
end

function _M:generate()
end
