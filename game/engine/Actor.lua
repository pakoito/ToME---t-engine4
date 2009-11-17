require "engine.class"
local Entity = require "engine.Entity"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(Entity))

function _M:init(t)
	t = t or {}
	self.name = t.name
	Entity.init(self, t)
end

function _M:move(map, x, y)
	if self.x and self.y then
		map:remove(self.x, self.y, Map.ACTOR)
	end
	if x < 0 then x = 0 end
	if x >= map.w then x = map.w - 1 end
	if y < 0 then y = 0 end
	if y >= map.h then y = map.h - 1 end
	self.x, self.y = x, y
	map(x, y, Map.ACTOR, self)
end
