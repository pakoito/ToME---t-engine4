require "engine.class"
require "engine.Object"

module(..., package.seeall, class.inherit(engine.Object))

function _M:init(t)
	engine.Object.init(self, t)
end

function _M:tooltip()
	return self:getName()
end
