require "engine.class"
module(..., package.seeall, class.make)

function _M:init(keyhandler)
	self.key = keyhandler
	self.level = nil
	self.w, self.h = core.display.size()
end

function _M:run()
end

function _M:setLevel(level)
	self.level = level
end

function _M:setCurrent()
	core.game.set_current_game(self)
	_M.current = self
end

function _M:display()
	if self.level and self.level.map then
		local s = self.level.map:display()
		if s then s:toScreen(0, 0) end
	end
end

-- This is the "main game loop", do something here
function _M:tick()

end
