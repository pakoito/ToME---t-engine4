require "engine.class"
require "tome.class.Actor"

module(..., package.seeall, class.inherit(tome.class.Actor))

function _M:init(game, t)
	tome.class.Actor.init(self, game, t)
end

function _M:act()
	self:move(self.x + 1, self.y)
end
