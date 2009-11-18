require "engine.class"
module(..., package.seeall, class.make)

function _M:init(keyhandler)
	self.key = keyhandler
	self.level = nil
end

function _M:setLevel(level)
	self.level = level
end

function _M:setCurrent()
	core.game.set_current_gametick(self)
end

-- This is the "main game loop", do something here
function _M:tick()

end
