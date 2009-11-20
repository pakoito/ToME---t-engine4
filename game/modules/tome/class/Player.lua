require "engine.class"
require "tome.class.Actor"

module(..., package.seeall, class.inherit(tome.class.Actor))

function _M:init(game, t)
	tome.class.Actor.init(self, game, t)
end

function _M:move(x, y, force)
	local moved = tome.class.Actor.move(self, x, y, force)
	return moved
end

function _M:act()
	self.game.paused = true
end
