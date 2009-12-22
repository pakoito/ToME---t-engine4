require "engine.class"
local Entity = require "engine.Entity"

module(..., package.seeall, class.inherit(Entity))

function _M:init(t, no_default)
	t = t or {}
	self.name = t.name
	Entity.init(self, t, no_default)
end
