require "engine.class"
require "engine.Actor"

module(..., package.seeall, class.inherit(engine.Actor))

function _M:init(t)
	engine.Actor.init(self, t)
end

function _M:move(map, x, y)
	engine.Actor.move(self, map, x, y)
end
