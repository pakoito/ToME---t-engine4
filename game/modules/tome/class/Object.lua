require "engine.class"
require "engine.Object"

module(..., package.seeall, class.inherit(engine.Object))

function _M:init(t)
	engine.Object.init(self, t)
end

function _M:tooltip()
	return self:getName()
end

--- Gets the full name of the object
function _M:getName()
	local qty = 1
	local name = self.name
	-- To extend later
	name = name:gsub("~", ""):gsub("#[1-9]#", ""):gsub("&", "a")
	return name
end

--- Gets the full desc of the object
function _M:getDesc()
	return self:getName()
end
