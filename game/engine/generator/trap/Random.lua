require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level)
	engine.Generator.init(self, zone, map)
	self.level = level
	local data = level.data.generator.trap

	self.filters = data.filters
	self.nb_trap = data.nb_trap or {10, 20}
	self.level_range = data.level_range or {level, level}
end

function _M:generate()
	for i = 1, rng.range(self.nb_trap[1], self.nb_trap[2]) do
		local f = nil
		if self.filters then f = self.filters[rng.range(1, #self.filters)] end
		local o = self.zone:makeEntity(self.level, "trap", f)
		if o then
			local x, y = rng.range(0, self.map.w), rng.range(0, self.map.h)
			local tries = 0
			while (self.map:checkEntity(x, y, Map.TERRAIN, "block_move") or self.map(x, y, Map.TRAP)) and tries < 100 do
				x, y = rng.range(0, self.map.w-1), rng.range(0, self.map.h-1)
				tries = tries + 1
			end
			if tries < 100 then
				self.map(x, y, Map.TRAP, o)
				o:added()
			end
		end
	end
end
