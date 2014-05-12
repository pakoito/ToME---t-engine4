-- TE4 - T-Engine 4
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
local ShowInventory = require_first("mod.dialogs.ShowInventory", "engine.dialogs.ShowInventory")
local ShowEquipment = require_first("mod.dialogs.ShowEquipment", "engine.dialogs.ShowEquipment")
local ShowEquipInven = require_first("mod.dialogs.ShowEquipInven", "engine.dialogs.ShowEquipInven")
local ShowPickupFloor = require_first("mod.dialogs.ShowPickupFloor", "engine.dialogs.ShowPickupFloor")

--- Handles actors stats
module(..., package.seeall, class.make)

_M.inven_def = {}

--- Defines stats
-- Static!
function _M:defineInventory(short_name, name, is_worn, desc, show_equip, infos)
	assert(name, "no inventory slot name")
	assert(short_name, "no inventory slot short_name")
	assert(desc, "no inventory slot desc")
	table.insert(self.inven_def, {
		name = name,
		short_name = short_name,
		description = desc,
		is_worn = is_worn,
		is_shown_equip = show_equip,
		infos = infos,
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
			self.inven[self["INVEN_"..inven]] = {max=max, worn=self.inven_def[self["INVEN_"..inven]].is_worn, id=self["INVEN_"..inven], name=inven}
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

--- Tells if an inventory still has room left
function _M:canAddToInven(id)
	if type(id) == "number" then
		return #self.inven[id] < self.inven[id].max
	elseif type(id) == "string" then
		return #self.inven[self["INVEN_"..id]] < self.inven[self["INVEN_"..id]].max
	else
		return id
	end
end

--- Adds an object to an inventory
-- @return false if the object could not be added otherwise true and the inventory index where it is now
function _M:addObject(inven_id, o)
	local inven = self:getInven(inven_id)

	-- No room ?
	if #inven >= inven.max then return false end

	if o:check("on_preaddobject", self, inven) then return false end

	-- Ok add it
	table.insert(inven, o)

	-- Do whatever is needed when wearing this object
	if inven.worn then
		self:onWear(o, self.inven_def[inven.id].short_name)
	end

	self:onAddObject(o)

	-- Make sure the object is registered with the game, if need be
	if not game:hasEntity(o) then game:addEntity(o) end

	return true, #inven
end

--- Returns the position of an item in the given inventory, or nil
function _M:itemPosition(inven, o)
	inven = self:getInven(inven)
	for i, p in ipairs(inven) do
		local found = nil
		o:forAllStack(function(so)
			if p.name == so.name then found = i return true end
		end)
		if found then return found end
	end
	return nil
end

--- Picks an object from the floor
function _M:pickupFloor(i, vocal, no_sort)
	if not self:getInven(self.INVEN_INVEN) then return end
	local o = game.level.map:getObject(self.x, self.y, i)
	if o then
		local prepickup = o:check("on_prepickup", self, i)
		if not prepickup and self:addObject(self.INVEN_INVEN, o) then
			game.level.map:removeObject(self.x, self.y, i)
			if not no_sort then self:sortInven(self.INVEN_INVEN) end

			o:check("on_pickup", self)
			self:check("on_pickup_object", o)

			local letter = ShowPickupFloor:makeKeyChar(self:itemPosition(self.INVEN_INVEN, o) or 1)
			if vocal then game.logSeen(self, "%s picks up (%s.): %s.", self.name:capitalize(), letter, o:getName{do_color=true}) end
			return o
		elseif not prepickup then
			if vocal then game.logSeen(self, "%s has no room for: %s.", self.name:capitalize(), o:getName{do_color=true}) end
			return
		elseif prepickup == "skip" then
			return
		else
			return true
		end
	else
		if vocal then game.logSeen(self, "There is nothing to pick up there.") end
	end
end

--- Removes an object from inventory
-- @param inven the inventory to drop from
-- @param item the item id to drop
-- @param no_unstack if the item was a stack takes off the whole stack if true
-- @return the object removed or nil if no item existed and a boolean saying if there is no more objects
function _M:removeObject(inven_id, item, no_unstack)
	local inven = self:getInven(inven_id)

	if not inven[item] then return false, true end

	local o, finish = inven[item], true

	if o:check("on_preremoveobject", self, inven) then return false, true end

	if not no_unstack then
		o, finish = o:unstack()
	end
	if finish then
		table.remove(inven, item)
	end

	-- Do whatever is needed when taking off this object
	if inven.worn then
		self:onTakeoff(o, self.inven_def[inven.id].short_name)
	end

	self:onRemoveObject(o)

	-- Make sure the object is registered with the game, if need be
	if not game:hasEntity(o) then game:addEntity(o) end

	return o, finish
end

--- Called upon adding an object
function _M:onAddObject(o)
	if self.__allow_carrier then
		-- Apply carrier properties
		o.carried = {}
		if o.carrier then
			for k, e in pairs(o.carrier) do
				o.carried[k] = self:addTemporaryValue(k, e)
			end
		end
	end
end

--- Called upon removing an object
function _M:onRemoveObject(o)
	if o.carried then
		for k, id in pairs(o.carried) do
			self:removeTemporaryValue(k, id)
		end
	end
	o.carried = nil
end

--- Called upon dropping an object
function _M:onDropObject(o)
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

	self:onDropObject(o)

	local ok, idx = game.level.map:addObject(self.x, self.y, o)

	if vocal then game.logSeen(self, "%s drops on the floor: %s.", self.name:capitalize(), o:getName{do_color=true}) end
	if ok and game.level.map.attrs(self.x, self.y, "on_drop") then
		game.level.map.attrs(self.x, self.y, "on_drop")(self, self.x, self.y, idx, o)
	end
	return true
end

--- Show combined equipment/inventory dialog
-- @param inven the inventory (from self:getInven())
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showEquipInven(title, filter, action, on_select)
	local d = ShowEquipInven.new(title, self, filter, action, on_select)
	game:registerDialog(d)
	return d
end

--- Show inventory dialog
-- @param inven the inventory (from self:getInven())
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showInventory(title, inven, filter, action)
	if not inven then return end
	local d = ShowInventory.new(title, inven, filter, action, self)
	game:registerDialog(d)
	return d
end

--- Show equipment dialog
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showEquipment(title, filter, action)
	local d = ShowEquipment.new(title, self, filter, action)
	game:registerDialog(d)
	return d
end

--- Show floor pickup dialog
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showPickupFloor(title, filter, action)
	local d = ShowPickupFloor.new(title, self.x, self.y, filter, action, nil, self)
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
				if type(tid) == "table" then
					if self:getTalentLevelRaw(tid[1]) < tid[2] then return nil, "missing dependency" end
				else
					if not self:knowTalent(tid) then return nil, "missing dependency" end
				end
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
		if self.inven_def[id].is_worn and (not self.inven_def[id].infos or not self.inven_def[id].infos.etheral) then
			for i, wo in ipairs(inven) do
				print("fight: ", o.name, wo.name, "::", wo.slot_forbid, try_slot or o.slot)
				if wo.slot_forbid and wo.slot_forbid == (try_slot or o.slot) then
					print(" impossible => ", o.name, wo.name, "::", wo.slot_forbid, try_slot or o.slot)
					return nil, "cannot use currently due to an other worn object"
				end
			end
		end
	end

	-- Any custom checks
	local err = self:check("canWearObjectCustom", o, try_slot)
	if err then return nil, err end

	return true
end

--- Returns the possible offslot
function _M:getObjectOffslot(o)
	return o.offslot
end

--- Wear/wield an item
function _M:wearObject(o, replace, vocal)
	local inven = o:wornInven()
	if not inven then
		if vocal then game.logSeen(self, "%s is not wearable.", o:getName{do_color=true}) end
		return false
	end
	if not self.inven[inven] then
		if vocal then game.logSeen(self, "%s can not wear %s.", self.name, o:getName{do_color=true}) end
		return false
	end

	local ok, err = self:canWearObject(o)
	if not ok then
		if vocal then game.logSeen(self, "%s can not wear: %s (%s).", self.name:capitalize(), o:getName{do_color=true}, err) end
		return false
	end
	if o:check("on_canwear", self, inven) then return false end
	local offslot = self:getObjectOffslot(o)

	if self:addObject(inven, o) then
		if vocal then game.logSeen(self, "%s wears: %s.", self.name:capitalize(), o:getName{do_color=true}) end
		return true
	elseif offslot and self:getInven(offslot) and #(self:getInven(offslot)) < self:getInven(offslot).max and self:canWearObject(o, offslot) then
		if vocal then game.logSeen(self, "%s wears(offslot): %s.", self.name:capitalize(), o:getName{do_color=true}) end
		-- Warning: assume there is now space
		self:addObject(self:getInven(offslot), o)
		return true
	elseif replace then
		local ro = self:removeObject(inven, 1, true)

		if vocal then game.logSeen(self, "%s wears(replacing): %s.", self.name:capitalize(), o:getName{do_color=true}) end

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
	inven = self:getInven(inven)
	if not inven then return false end

	local o = inven[item]
	if o:check("on_cantakeoff", self, inven) then return false end

	o = self:removeObject(inven, item, true)
	return o
end

--- Call when an object is worn
function _M:onWear(o, inven_id)
	-- Apply wielder properties
	o.wielded = {}
	o:check("on_wear", self, inven_id)
	if o.wielder then
		for k, e in pairs(o.wielder) do
			o.wielded[k] = self:addTemporaryValue(k, e)
		end
	end
end

--- Call when an object is taken off
function _M:onTakeoff(o, inven_id)
	if o.wielded then
		for k, id in pairs(o.wielded) do
			if type(id) == "table" then
				self:removeTemporaryValue(id[1], id[2])
			else
				self:removeTemporaryValue(k, id)
			end
		end
	end
	o:check("on_takeoff", self, inven_id)
	o.wielded = nil
end

--- Re-order inventory, sorting and stacking it
function _M:sortInven(inven)
	if not inven then inven = self.inven[self.INVEN_INVEN] end
	inven = self:getInven(inven)
	if not inven then return end

	-- Stack objects first, from bottom
	for i = #inven, 1, -1 do
		-- If it is stackable, look for objects before it that it could stack into
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
	self.changed = true
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

--- Finds an object by property in an inventory
-- @param inven the inventory to look into
-- @param prop the property to look for
-- @param value the value to look for, can be a function
function _M:findInInventoryBy(inven, prop, value)
	if type(value) == "function" then
		for item, o in ipairs(inven) do
			if value(o[prop]) then return o, item end
		end
	else
		for item, o in ipairs(inven) do
			if o[prop] == value then return o, item end
		end
	end
end

--- Finds an object by property in all the actor's inventories
-- @param prop the property to look for
-- @param value the value to look for, can be a function
function _M:findInAllInventoriesBy(prop, value)
	for inven_id, inven in pairs(self.inven) do
		local o, item = self:findInInventoryBy(inven, prop, value)
		if o and item then return o, item, inven_id end
	end
end

--- Applies fct over all items
-- @param inven the inventory to look into
-- @param fct the function to be called. It will receive three parameters: inven, item, object
function _M:inventoryApply(inven, fct)
	for item, o in ipairs(inven) do
		fct(inven, item, o)
	end
end

--- Applies fct over all items in all inventories
-- @param inven the inventory to look into
-- @param fct the function to be called. It will receive three parameters: inven, item, object
function _M:inventoryApplyAll(fct)
	for inven_id, inven in pairs(self.inven) do
		self:inventoryApply(inven, fct)
	end
end

--- Empties given inventory and marks items inside as never generated
function _M:forgetInven(inven)
	inven = self:getInven(inven)
	if not inven then return end

	for i = #inven, 1, -1 do
		local o = inven[i]

		self:removeObject(inven, i, true)
		o:removed()
	end
end
