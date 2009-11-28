require "engine.class"

--- Handles actors life and death
module(..., package.seeall, class.make)

function _M:init(t)
	self.life = t.life or 100
end

--- Checks if something bumps in us
-- If it happens the method attack is called on the target with the attacker as parameter.
-- Do not touch!
function _M:block_move(x, y, e)
	-- Dont bump yourself!
	if e and e ~= self then
		e:attack(self)
	end
	return true
end

--- Remove some HP from an actor
-- If HP is reduced to 0 then remove from the level and call the die method
function _M:takeHit(value, src)
	self.life = self.life - value
	if self.life <= 0 then
		game.logSeen(self, "%s killed %s!", src.name:capitalize(), self.name)
		game.level:removeEntity(self)
		return self:die(src)
	end
end

--- Actor is being attacked!
-- Module authors should rewrite it to handle combat, dialog, ...
-- @param target the actor attacking us
function _M:attack(target)
	game.logSeen(target, "%s attacks %s.", self.name:capitalize(), target.name:capitalize())
	target:takeHit(10, self)
end
