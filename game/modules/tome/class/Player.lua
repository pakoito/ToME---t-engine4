require "engine.class"
require "mod.class.Actor"

module(..., package.seeall, class.inherit(mod.class.Actor))

function _M:init(t)
	mod.class.Actor.init(self, t)
	self.player = true
	self.faction = "players"
	self.combat = { dam=10, atk=4, apr=2, def=6, armor=4 }
end

function _M:move(x, y, force)
	local moved = mod.class.Actor.move(self, x, y, force)
	return moved
end

function _M:act()
	game.paused = true
end

function _M:die()
	-- a tad brutal
	os.exit()
end
