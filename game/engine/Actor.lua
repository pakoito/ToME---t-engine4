require "engine.class"
local Entity = require "engine.Entity"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(Entity))

function _M:move(map, x, y)
	if self.x and self.y then
		map:remove(self.x, self.y, Map.ACTOR)
	end
	self.x, self.y = x, y
	map(x, y, Map.ACTOR, self)
end
