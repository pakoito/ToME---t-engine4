require "engine.class"
require "tome.class.Actor"

module(..., package.seeall, class.inherit(tome.class.Actor))

function _M:init(game, t)
	tome.class.Actor.init(self, game, t)
end

function _M:move(x, y, force)
	local moved = tome.class.Actor.move(self, x, y, force)
	if self.x and self.y then
		self.game.level.map.fov(self.x, self.y, 20)
		self.game.level.map.seens(self.x, self.y, true)
	end
	return moved
end

function _M:act()
	self.game.paused = true
end
