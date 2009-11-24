require "engine.class"
require "mod.class.Actor"

module(..., package.seeall, class.inherit(mod.class.Actor))

function _M:init(t)
	mod.class.Actor.init(self, t)
end

function _M:act()
	self:move(self.x + 1, self.y)
end
