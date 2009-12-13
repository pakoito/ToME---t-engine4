require "engine.class"
local Map = require "engine.Map"
local ShowInventory = require "engine.dialogs.ShowInventory"
local ShowEquipment = require "engine.dialogs.ShowEquipment"

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
	if type(id) == "number" then
		return self.inven[id]
	else
		return id
	end
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
	if type(inven) == "number" then inven = self.inven[inven] end
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
function _M:showInventory(title, inven, filter, action)
	local d = ShowInventory.new(title, inven, filter, action)
	game:registerDialog(d)
end

--- Show equipment dialog
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showEquipment(title, filter, action)
	local d = ShowEquipment.new(title, self, filter, action)
	game:registerDialog(d)
end

--- Wear/wield an item
function _M:wearObject(o, replace, vocal)
	local inven = o:wornInven()
	if not o then
		if vocal then game.logSeen(self, "%s is not wearable.", o:getName()) end
		return false
	end
	if self:addObject(inven, o) then
		if vocal then game.logSeen(self, "%s wears: %s.", self.name:capitalize(), o:getName()) end
		return true
	elseif replace then
		local ro = self:removeObject(inven, 1)
		-- Warning: assume there is now space
		self:addObject(inven, o)
		return ro
	else
		if vocal then game.logSeen(self, "%s can not wear: %s.", self.name:capitalize(), o:getName()) end
		return false
	end
end

--- Takeoff item
function _M:takeoffObject(inven, item)
	inven = self:getInven(inven)
	local o = table.remove(inven, item)
	return o
end
