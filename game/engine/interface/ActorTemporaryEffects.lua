require "engine.class"

--- Handles actors temporary effects (temporary boost of a stat, ...)
module(..., package.seeall, class.make)

function _M:init(t)
	self.tmp = {}
end
