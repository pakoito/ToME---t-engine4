require "engine.class"

module(..., package.seeall, class.make)

function _M:init(t)
	self.life = t.life or 100
end

function _M:block_move(x, y, e)
	-- Dont bump yourself!
	if e and e ~= self then
		e:attack(self)
	end
	return true
end

function _M:takeHit(value, src)
	self.life = self.life - value
	if self.life <= 0 then
		game.logSeen(self, "%s killed %s!", src.name:capitalize(), self.name)
		game.level:removeEntity(self)
		self:die(src)
	end
end

function _M:attack(target)
	game.logSeen(target, "%s attacks %s.", self.name:capitalize(), target.name:capitalize())
	target:takeHit(10, self)
end
