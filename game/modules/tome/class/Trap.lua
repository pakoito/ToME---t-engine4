require "engine.class"
require "engine.Trap"

module(..., package.seeall, class.inherit(
	engine.Trap
))

function _M:init(t, no_default)
	engine.Trap.init(self, t, no_default)
end

--- Returns a tooltip for the trap
function _M:tooltip()
	return self.name
end
