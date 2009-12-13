require "engine.class"
local Entity = require "engine.Entity"

module(..., package.seeall, class.inherit(Entity))

function _M:init(t)
	t = t or {}
	Entity.init(self, t)
end

function _M:resolve(t)
	Entity.resolve(self, t)
	self.egos = nil
end

--- Gets the full name of the object
function _M:getName()
	return self.name
end

--- Gets the full desc of the object
function _M:getDesc()
	return self.name
end

--- Returns the inventory type an object is worn on
function _M:wornInven()
	if not self.slot then return nil end
	local invens = require "engine.interface.ActorInventory"
	return invens["INVEN_"..self.slot]
end
