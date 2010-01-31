require "engine.class"

--- Handles unidentified objects, and their identification
module(..., package.seeall, class.make)

function _M:init(t)
	if t.identified ~= nil then
		self.identified = t.identified
	else
		self.identified = false
	end
end

--- Defines the default ided status
function _M:resolveIdentify()
	if not self.unided_name then
		self.unided_name = self.name
	end
end

--- Can this object be identified at all ?
-- Defaults to true, you can overload it
function _M:canIdentify()
	return true
end

--- Is the object identified ?
function _M:isIdentified()
	-- Auto id by type ?
	if game.object_known_types and game.object_known_types[self.type] and game.object_known_types[self.type][self.subtype] and game.object_known_types[self.type][self.subtype][self.name] then
		self.identified = game.object_known_types[self.type][self.subtype][self.name]
	end

	return self.identified
end

--- Identify the object
function _M:identify(id)
	self.identified = id
	if self.id_by_type then
		game.object_known_types = game.object_known_types or {}
		game.object_known_types[self.type] = game.object_known_types[self.type] or {}
		game.object_known_types[self.type][self.subtype] = game.object_known_types[self.type][self.subtype] or {}
		game.object_known_types[self.type][self.subtype][self.name] = id
	end
end

--- Get the unided name
function _M:getUnidentifiedName()
	return self.unided_name
end
