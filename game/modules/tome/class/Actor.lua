require "engine.class"
require "engine.Actor"

module(..., package.seeall, class.inherit(engine.Actor))

function _M:init(t)
	t.block_move = _M.bumped
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

function _M:bumped(x, y, e)
	-- Dont bump yourself!
	if e and e ~= self then
		game.log("%s bumped into %s!", tostring(e.name), tostring(self.name))
	end
	return true
end

function _M:tooltip()
	return self.name.."\n#ff0000#HP: "..self.life
end
