require "engine.class"
local Map = require "engine.Map"
local ShowInventory = require "engine.dialogs.ShowInventory"
local ShowEquipment = require "engine.dialogs.ShowEquipment"
local ShowPickupFloor = require "engine.dialogs.ShowPickupFloor"

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
	elseif type(id) == "string" then
		return self.inven[self["INVEN_"..id]]
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

	-- Do whatever is needed when wearing this object
	if self.inven[inven].worn then self:onWear(o) end

	return true
end

--- Picks an object from the floor
function _M:pickupFloor(i, vocal)
	local o = game.level.map:getObject(self.x, self.y, i)
	if o then
		if self:addObject(self.INVEN_INVEN, o) then
			game.level.map:removeObject(self.x, self.y, i)

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
	local o = inven[item]
	local o, finish = o:unstack()
	if finish then
		table.remove(inven, item)
	end

	-- Do whatever is needed when takingoff this object
	print("remove object", inven, inven.max, inven.worn, item, o)
	if inven.worn then self:onTakeoff(o) end

	return o
end

--- Drop an object on the floor
-- @param inven the inventory to drop from
-- @param item the item id to drop
-- @return the object removed or nil if no item existed
function _M:dropFloor(inven, item, vocal)
	local o = self:removeObject(inven, item)
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

--- Show floor pickup dialog
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showPickupFloor(title, filter, action)
	local d = ShowPickupFloor.new(title, self.x, self.y, filter, action)
	game:registerDialog(d)
end

--- Can we wear this item?
function _M:canWearObject(o)
	local req = rawget(o, "require")

	-- Check prerequisites
	if req then
		-- Obviously this requires the ActorStats interface
		if req.stat then
			for s, v in pairs(req.stat) do
				if self:getStat(s) < v then return nil, "not enough stat" end
			end
		end
		if req.level and self.level < req.level then
			return nil, "not enough levels"
		end
		if req.talent then
			for _, tid in ipairs(req.talent) do
				if not self:knowTalent(tid) then return nil, "missing dependency" end
			end
		end
	end

	-- Check forbidden slot
	if o.slot_forbid then
		local inven = self:getInven(o.slot_forbid)
		-- If the object cant coexist with that inventory slot and it exists and is not empty, refuse wearing
		if inven and #inven > 0 then
			return nil, "cannot use currently due to an other worn object"
		end
	end

	-- Check that we are not the forbidden slot of any other worn objects
	for id, inven in pairs(self.inven) do
		if self.inven_def[id].is_worn then
			for i, wo in ipairs(inven) do
				if wo.slot_forbid and wo.slot_forbid == o.slot then
					return nil, "cannot use currently due to an other worn object"
				end
			end
		end
	end

	return true
end

--- Wear/wield an item
function _M:wearObject(o, replace, vocal)
	local inven = o:wornInven()
	if not inven then
		if vocal then game.logSeen(self, "%s is not wearable.", o:getName()) end
		return false
	end
	local ok, err = self:canWearObject(o)
	if not ok then
		if vocal then game.logSeen(self, "%s can not wear: %s (%s).", self.name:capitalize(), o:getName(), err) end
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
	local o = self:removeObject(inven, item)
	return o
end

--- Call when an object is worn
function _M:onWear(o)
	-- Apply wielder properties
	if o.wielder then
		o.wielded = {}
		for k, e in pairs(o.wielder) do
			o.wielded[k] = self:addTemporaryValue(k, e)
		end
	end
end

--- Call when an object is taken off
function _M:onTakeoff(o)
	if o.wielded then
		for k, id in pairs(o.wielded) do
			self:removeTemporaryValue(k, id)
		end
	end
	o.wielded = nil
end

--- Re-order inventory, sorting and stacking it
function _M:sortInven(inven)
	if not inven then inven = self.inven[self.INVEN_INVEN] end

	-- Stack objects first, from bottom
	for i = #inven, 1, -1 do
		-- If it is stackable, look for obejcts before it that it could stack into
		if inven[i]:stackable() then
			for j = i - 1, 1, -1 do
				if inven[j]:stack(inven[i]) then
					print("Stacked objects", i, inven[i].name, "into", j, inven[j].name)
					table.remove(inven, i)
					break
				end
			end
		end
	end

	-- Sort them
	table.sort(inven, function(a, b)
		local ta, tb = a:getTypeOrder(), b:getTypeOrder()
		local sa, sb = a:getSubtypeOrder(), b:getSubtypeOrder()
		if ta == tb then
			if sa == sb then
				return a.name < b.name
			else
				return sa < sb
			end
		else
			return ta < tb
		end
	end)
end
