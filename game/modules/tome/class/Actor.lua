require "engine.class"
require "engine.Actor"

module(..., package.seeall, class.inherit(engine.Actor))

function _M:init(game, t)
	self.game = game
	t.block_move = _M.bumped
	engine.Actor.init(self, t)
end

function _M:move(x, y, force)
	local moved = false
	if force or self.energy.value >= self.game.energy_to_act then
		moved = engine.Actor.move(self, self.game.level.map, x, y)
		if not force then self.energy.value = self.energy.value - self.game.energy_to_act end
	end
	return moved
end

function _M:bumped(x, y, e)
	self.game.log("%s bumped into %s!", tostring(e.name), tostring(self.name))
	return true
end
