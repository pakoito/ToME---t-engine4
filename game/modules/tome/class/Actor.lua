require "engine.class"
require "engine.Actor"
require "engine.interface.ActorLife"
require "engine.interface.ActorLevel"

module(..., package.seeall, class.inherit(engine.Actor, engine.interface.ActorLife, engine.interface.ActorLevel))

function _M:init(t)
	engine.Actor.init(self, t)
	engine.interface.ActorLife.init(self, t)
	engine.interface.ActorLevel.init(self, t)
end

function _M:move(x, y, force)
	local moved = false
	if force or self.energy.value >= game.energy_to_act then
		moved = engine.Actor.move(self, game.level.map, x, y, force)
		if not force then self.energy.value = self.energy.value - game.energy_to_act end
	end
	return moved
end

function _M:tooltip()
	return self.name.."\n#ff0000#HP: "..self.life
end

function _M:die(src)
	if src then
		src:gainExp(self:worthExp())
	end
end
