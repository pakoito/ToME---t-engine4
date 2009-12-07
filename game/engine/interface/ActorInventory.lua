require "engine.class"

--- Handles actors stats
module(..., package.seeall, class.make)

_M.inven_def = {}

--- Defines stats
-- Static!
function _M:defineInventory(short_name, name, is_worn, desc)
	assert(name, "no inventory slot name")
	assert(short_name, "no inventory slot short_name")
	assert(desc, "no inventory slot desc")
	table.insert(self.inven_def, {
		name = name,
		short_name = short_name,
		description = desc,
		is_worn = is_worn,
	})
	self.inven_def[#self.inven_def].id = #self.inven_def
	self.inven_def[short_name] = self.inven_def[#self.inven_def]
	self["INVEN_"..short_name:upper()] = #self.inven_def
end

--- Initialises inventories with default values if needed
function _M:init(t)
	self.inven = t.inven or {}
	if t.body then
		for inven, max in pairs(t.body) do
			self.inven[self["INVEN_"..inven]] = {}
		end
	end
end

function _M:pickup()
end
