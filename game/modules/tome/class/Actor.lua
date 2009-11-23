require "engine.class"
require "engine.Actor"

module(..., package.seeall, class.inherit(engine.Actor))

function _M:init(t)
	self.level = 1
	self.life = 100
	self.mana = 100
	self.skills = {}
	self.attacks = {}
	engine.Actor.init(self, t)
end

-- When saving, ignore some fields
function _M:save()
	return engine.Actor.save(self, {game=true})
end

function _M:move(x, y, force)
	local moved = false
	if force or self.energy.value >= game.energy_to_act then
		moved = engine.Actor.move(self, game.level.map, x, y, force)
		if not force then self.energy.value = self.energy.value - game.energy_to_act end
	end
	return moved
end

function _M:block_move(x, y, e)
	-- Dont bump yourself!
	if e and e ~= self then
		game.log("%s attacks %s.", tostring(e.name), tostring(self.name))
		self:takeHit(10, e)
	end
	return true
end

function _M:tooltip()
	return self.name.."\n#ff0000#HP: "..self.life
end

function _M:takeHit(value, src)
	self.life = self.life - value
	if self.life <= 0 then
		game.log("%s killed %s!", src.name, self.name)
		game.level:removeEntity(self)
		self:die()
	end
end

function _M:die()
end
