require "engine.class"
module(..., package.seeall, class.make)

function _M:init(keyhandler)
	self.key = keyhandler
	self.level = nil
end

function _M:setLevel(level)
	self.level = level
end
