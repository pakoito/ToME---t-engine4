require "engine.class"
require "engine.Actor"

module(..., package.seeall, class.inherit(engine.Actor))

function _M:init(game, t)
	self.game = game
	engine.Actor.init(self, t)
end

function _M:move(x, y)
	engine.Actor.move(self, self.game.level.map, x, y)
	self.game.level.map.fov(self.x, self.y, 20)
	self.game.level.map.seens(self.x, self.y, true)
end
