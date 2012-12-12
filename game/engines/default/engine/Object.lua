-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
local Entity = require "engine.Entity"

module(..., package.seeall, class.inherit(Entity))

_M.display_on_seen = true
_M.display_on_remember = true
_M.display_on_unknown = false

function _M:init(t, no_default)
	t = t or {}

	self.energy = t.energy or { value=0 }
	self.energy.value = self.energy.value or 0

	Entity.init(self, t, no_default)
end

--- Resolves the object
-- This will call the entities resolver and then add to the game entities list
function _M:resolve(t, last, on_entity)
	engine.Entity.resolve(self, t, last, on_entity)

	if not t and last then
		-- Stackable property is the name by default
		if self.stacking and type(self.stacking) == "boolean" then
			self.stacking = self:getName{no_count=true, force_id=true}
		end

		-- Auto add all objects to the game, if they can act
		game:addEntity(self)
	end
end

--- Loaded, we add ourself back to the game
function _M:loaded()
	engine.Entity.loaded(self)

	if not game:hasEntity(self) then game:addEntity(self) end
end

--- Can this object act at all
-- Most object will want to answer false, only recharging and stuff needs them
function _M:canAct()
	return false
end

--- Setup minimap color for this entity
-- You may overload this method to customize your minimap
function _M:setupMinimapInfo(mo, map)
	mo:minimap(0, 0, 240)
end

--- Do something when its your turn
-- For objects this mostly is to recharge them
-- By default, does nothing at all
function _M:act()
end

--- Gets the color in which to display the object in lists
function _M:getDisplayColor()
	return {255,255,255}
end

--- Gets the full name of the object
function _M:getName(t)
	t = t or {}
	local qty = self:getNumber()
	local name = self.name

	if qty == 1 or t.no_count then return name
	else return qty.." "..name
	end
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

--- Do we have enough energy
function _M:enoughEnergy(val)
	val = val or game.energy_to_act
	return self.energy.value >= val
end

--- Use some energy
function _M:useEnergy(val)
	val = val or game.energy_to_act
	self.energy.value = self.energy.value - val
end

--- Stackable, can it stack at all ?
function _M:stackable()
	return self.stacking
end

--- Can it stacks with others of its kind ?
function _M:canStack(o)
	if not self.stacking or not o.stacking then return false end
	if  self.stacking == o.stacking then return true end
	return false
end

--- Adds object to the stack
-- @return true if stacking worked, false if not
function _M:stack(o, force)
	if not force and not self:canStack(o) then return false end
	self.stacked = self.stacked or {}
	self.stacked[#self.stacked+1] = o

	-- Merge stacks
	if o.stacked then
		for i = 1, #o.stacked do
			self.stacked[#self.stacked+1] = o.stacked[i]
		end
		o.stacked = nil
	end
	return true
end

--- Removes an object of the stack
-- @return object, true if the last, or object, false if more
function _M:unstack()
	if not self:stackable() or not self.stacked or #self.stacked == 0 then return self, true end
	local o = table.remove(self.stacked)
	if #self.stacked == 0 then self.stacked = nil end
	return o, false
end

--- Applies a function to all items of the stack
function _M:forAllStack(fct)
	fct(self)
	if not self.stacked then return end
	for i, so in ipairs(self.stacked) do
		if fct(so, i) then break end
	end
end

--- Returns the number of objects available
-- Always one for non stacking objects
function _M:getNumber()
	if not self.stacked then return 1 end
	return 1 + #self.stacked
end

--- Sorting by type function
-- By default, sort by type name
function _M:getTypeOrder()
	return self.type or ""
end

--- Sorting by type function
-- By default, sort by subtype name
function _M:getSubtypeOrder()
	return self.subtype or ""
end

--- Describe requirements
function _M:getRequirementDesc(who)
	local req = rawget(self, "require")
	if not req then return nil end

	local str = tstring{"Requires:", true}

	if req.stat then
		for s, v in pairs(req.stat) do
			local c = (who:getStat(s) >= v) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
			str:add(c, "- ", ("%s %d"):format(who.stats_def[s].name, v), {"color", "LAST"}, true)
		end
	end
	if req.level then
		local c = (who.level >= req.level) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
		str:add(c, "- ", ("Level %d"):format(req.level), {"color", "LAST"}, true)
	end
	if req.talent then
		for _, tid in ipairs(req.talent) do
			if type(tid) == "table" then
				local c = (who:getTalentLevelRaw(tid[1]) >= tid[2]) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
				str:add(c, "- ", ("Talent %s (level %d)"):format(who:getTalentFromId(tid[1]).name, tid[2]), {"color", "LAST"}, true)
			else
				local c = who:knowTalent(tid) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
				str:add(c, "- ", ("Talent %s"):format(who:getTalentFromId(tid).name), {"color", "LAST"}, true)
			end
		end
	end
	str:add(true)
	return str
end

--- Returns a map object that represents how many are in the stack
local stackmo = {}
function _M:getMapStackMO(map, x, y)
	local nb = map:getObjectTotal(x, y)
	if nb < 2 then return end
	if nb > 9 then nb = "many" end
	if stackmo[nb] then return stackmo[nb] end

	local s
	if Map.tiles then
		s = Map.tiles:loadImage("objstack"..nb..".png")
	else
		s = core.display.loadImage("/data/gfx/objstack"..nb..".png")
	end
	if not s then return end
	local tex = s:glTexture()

	-- Create the map object with 1 + additional textures
	local _mo = core.map.newObject(0, 1, self:check("display_on_seen"), self:check("display_on_remember"), self:check("display_on_unknown"), 0, 0, 1, 1, 1)
	_mo:texture(0, tex, false, 1, 1, 0, 0)
	stackmo[nb] = _mo

	return _mo
end

--- Return the kind of the entity
function _M:getEntityKind()
	return "object"
end
