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
	if force or self:enoughEnergy() then
		moved = engine.Actor.move(self, game.level.map, x, y, force)
		if not force then self:useEnergy() end
	end
	return moved
end

function _M:tooltip()
	return ("%s\n#00ffff#Level: %d\nExp: %d/%d\n#ff0000#HP: %d"):format(self.name, self.level, self.exp, self:getExpChart(self.level+1) or "---", self.life)
end

function _M:die(src)
	-- Gives the killer some exp for the kill
	if src then
		src:gainExp(self:worthExp())
	end
end

function _M:levelup()

end
