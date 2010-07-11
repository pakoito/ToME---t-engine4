-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

require "engine.class"
local Map = require "engine.Map"
local ShowInventory = require "engine.dialogs.ShowInventory"
local ShowEquipment = require "engine.dialogs.ShowEquipment"
local ShowEquipInven = require "engine.dialogs.ShowEquipInven"
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
	print("[INVENTORY] define slot", #self.inven_def, self.inven_def[#self.inven_def].name)
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
function _M:addObject(inven_id, o)
	local inven
	if type(inven_id) == "number" then
		inven = self.inven[inven_id]
	else
		inven = inven_id
	end

	-- No room ?
	if #inven >= inven.max then return false end

	if o:check("on_preaddobject", self, inven) then return false end

	-- Ok add it
	table.insert(inven, o)

	-- Do whatever is needed when wearing this object
	if inven.worn then
		o:check("on_wear", self)
		self:onWear(o)
	end

	self:onAddObject(o)

	return true
end

--- Called upon adding an object
function _M:onAddObject(o)
end

--- Picks an object from the floor
function _M:pickupFloor(i, vocal)
	local o = game.level.map:getObject(self.x, self.y, i)
	if o then
		local prepickup = o:check("on_prepickup", self, i)
		if not prepickup and self:addObject(self.INVEN_INVEN, o) then
			game.level.map:removeObject(self.x, self.y, i)
			o:check("on_pickup", self)

			if vocal then game.logSeen(self, "%s picks up: %s.", self.name:capitalize(), o:getName{do_color=true}) end
		elseif not prepickup then
			if vocal then game.logSeen(self, "%s has no room for: %s.", self.name:capitalize(), o:getName{do_color=true}) end
		end
	else
		if vocal then game.logSeen(self, "There is nothing to pickup there.") end
	end
end

--- Removes an object from inventory
-- @param inven the inventory to drop from
-- @param item the item id to drop
-- @param no_unstack if the item was a stack takes off the whole stack if true
-- @return the object removed or nil if no item existed and a boolean saying if there is no more objects
function _M:removeObject(inven, item, no_unstack)
	if type(inven) == "number" then inven = self.inven[inven] end

	if not inven[item] then return false, true end

	local o, finish = inven[item], true

	if o:check("on_preremoveobject", self, inven) then return false, true end

	if not no_unstack then
		o, finish = o:unstack()
	end
	if finish then
		table.remove(inven, item)
	end

	-- Do whatever is needed when takingoff this object
	if inven.worn then
		o:check("on_takeoff", self)
		self:onTakeoff(o)
	end

	self:onRemoveObject(o)

	return o, finish
end

--- Called upon removing an object
function _M:onRemoveObject(o)
end

--- Drop an object on the floor
-- @param inven the inventory to drop from
-- @param item the item id to drop
-- @return the object removed or nil if no item existed
function _M:dropFloor(inven, item, vocal, all)
	local o = self:getInven(inven)[item]
	if not o then
		if vocal then game.logSeen(self, "There is nothing to drop.") end
		return
	end
	if o:check("on_drop", self) then return false end
	o = self:removeObject(inven, item, all)
	game.level.map:addObject(self.x, self.y, o)
	if vocal then game.logSeen(self, "%s drops on the floor: %s.", self.name:capitalize(), o:getName{do_color=true}) end
	return true
end

--- Show combined equipment/inventory dialog
-- @param inven the inventory (from self:getInven())
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showEquipInven(title, filter, action, allow_keybind)
	local d = ShowEquipInven.new(title, self, filter, action, allow_keybind and self)
	game:registerDialog(d)
	return d
end

--- Show inventory dialog
-- @param inven the inventory (from self:getInven())
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showInventory(title, inven, filter, action, allow_keybind)
	local d = ShowInventory.new(title, inven, filter, action, allow_keybind and self)
	game:registerDialog(d)
	return d
end

--- Show equipment dialog
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showEquipment(title, filter, action, allow_keybind)
	local d = ShowEquipment.new(title, self, filter, action, allow_keybind and self)
	game:registerDialog(d)
	return d
end

--- Show floor pickup dialog
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showPickupFloor(title, filter, action)
	local d = ShowPickupFloor.new(title, self.x, self.y, filter, action)
	game:registerDialog(d)
	return d
end

--- Can we wear this item?
function _M:canWearObject(o, try_slot)
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
				print("fight: ", o.name, wo.name, "::", wo.slot_forbid, try_slot or o.slot)
				if wo.slot_forbid and wo.slot_forbid == (try_slot or o.slot) then
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
		if vocal then game.logSeen(self, "%s is not wearable.", o:getName{do_color=true}) end
		return false
	end
	print("wear slot", inven)
	local ok, err = self:canWearObject(o)
	if not ok then
		if vocal then game.logSeen(self, "%s can not wear: %s (%s).", self.name:capitalize(), o:getName{do_color=true}, err) end
		return false
	end
	if o:check("on_canwear", self, inven) then return false end

	if self:addObject(inven, o) then
		if vocal then game.logSeen(self, "%s wears: %s.", self.name:capitalize(), o:getName{do_color=true}) end
		return true
	elseif o.offslot and self:getInven(o.offslot) and #(self:getInven(o.offslot)) < self:getInven(o.offslot).max and self:canWearObject(o, o.offslot) then
		if vocal then game.logSeen(self, "%s wears(offslot): %s.", self.name:capitalize(), o:getName{do_color=true}) end
		-- Warning: assume there is now space
		self:addObject(self:getInven(o.offslot), o)
		return true
	elseif replace then
		local ro = self:removeObject(inven, 1, true)

		if vocal then game.logSeen(self, "%s wears: %s.", self.name:capitalize(), o:getName{do_color=true}) end

		-- Can we stack the old and new one ?
		if o:stack(ro) then ro = true end

		-- Warning: assume there is now space
		self:addObject(inven, o)
		return ro
	else
		if vocal then game.logSeen(self, "%s can not wear: %s.", self.name:capitalize(), o:getName{do_color=true}) end
		return false
	end
end

--- Takeoff item
function _M:takeoffObject(inven, item)
	local o = self:getInven(inven)[item]
	if o:check("on_cantakeoff", self, inven) then return false end

	o = self:removeObject(inven, item, true)
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

--- Finds an object by name in an inventory
-- @param inven the inventory to look into
-- @param name the name to look for
-- @param getname the parameters to pass to getName(), if nil the default is {no_count=true, force_id=true}
function _M:findInInventory(inven, name, getname)
	getname = getname or {no_count=true, force_id=true}
	for item, o in ipairs(inven) do
		if o:getName(getname) == name then return o, item end
	end
end

--- Finds an object by name in all the actor's inventories
-- @param name the name to look for
-- @param getname the parameters to pass to getName(), if nil the default is {no_count=true, force_id=true}
function _M:findInAllInventories(name, getname)
	for inven_id, inven in pairs(self.inven) do
		local o, item = self:findInInventory(inven, name, getname)
		if o and item then return o, item, inven_id end
	end
end
