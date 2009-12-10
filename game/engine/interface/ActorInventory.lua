require "engine.class"
local Map = require "engine.Map"
local ShowInventory = require "engine.dialogs.ShowInventory"

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

-- Auto define the inventory
_M:defineInventory("INVEN", "In inventory", false, "")

--- Initialises inventories with default values if needed
function _M:init(t)
	self.inven = t.inven or {}
	self:initBody()
end

function _M:initBody()
	if self.body then
		for inven, max in pairs(self.body) do
			self.inven[self["INVEN_"..inven]] = {max=max, worn=self.inven_def[self["INVEN_"..inven]].is_worn}
		end
		self.body = nil
	end
end

--- Returns the content of an inventory as a table
function _M:getInven(id)
	return self.inven[id]
end

--- Adds an object to an inventory
-- @return false if the object could not be added
function _M:addObject(inven, o)
	-- No room ?
	if #self.inven[inven] >= self.inven[inven].max then return false end

	-- Ok add it
	table.insert(self.inven[inven], o)
	return true
end

--- Picks an object from the floor
function _M:pickupFloor(i, vocal)
	i = i - 1 + Map.OBJECT
	local o = game.level.map(self.x, self.y, i)
	if o then
		if self:addObject(self.INVEN_INVEN, o) then
			game.level.map:remove(self.x, self.y, i)

			if vocal then game.logSeen(self, "%s picks up: %s.", self.name:capitalize(), o:getName()) end
		else
			if vocal then game.logSeen(self, "%s has no room for: %s.", self.name:capitalize(), o:getName()) end
		end
	else
		if vocal then game.logSeen(self, "There is nothing to pickup there.") end
	end
end

--- Removes an object from inventory
-- @param inven the inventory to drop from
-- @param item the item id to drop
-- @return the object removed or nil if no item existed
function _M:removeObject(inven, item)
	return table.remove(inven, item)
end

--- Drop an object on the floor
-- @param inven the inventory to drop from
-- @param item the item id to drop
-- @return the object removed or nil if no item existed
function _M:dropFloor(inven, item, vocal)
	local o = table.remove(inven, item)
	if not o then
		if vocal then game.logSeen(self, "There is nothing to drop.") end
		return
	end
	game.level.map:addObject(self.x, self.y, o)
	if vocal then game.logSeen(self, "%s drops on the floor: %s.", self.name:capitalize(), o:getName()) end
end

--- Show inventory dialog
-- @param inven the inventory (from self:getInven())
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showInventory(inven, filter, action)
	local d = ShowInventory.new(inven, filter, action)
	game:registerDialog(d)
end
