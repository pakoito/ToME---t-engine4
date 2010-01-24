require "engine.class"
local Entity = require "engine.Entity"

module(..., package.seeall, class.inherit(Entity))

function _M:init(t, no_default)
	t = t or {}

	self.energy = t.energy or { value=0, mod=1 }
	self.energy.value = self.energy.value or 0
	self.energy.mod = self.energy.mod or 0

	Entity.init(self, t, no_default)
end

--- Resolves the object
-- This will call the entities resolver and then add to the game entities list
function _M:resolve(t)
	if not t then
		-- Handle ided if possible
		if self.resolveIdentify then
			self:resolveIdentify()
		end
	end

	engine.Entity.resolve(self, t)

	if not t then
		-- Stackable property is the name by default
		if self.stacking and type(self.stacking) == "boolean" then
			self.stacking = self.name
		end

		-- Auto add all objects to the game, if they can act
		game:addEntity(self)
	end
end

--- Can this object act at all
-- Most object will want to anwser false, only recharging and stuff needs them
function _M:canAct()
	return false
end

--- Do something when its your turn
-- For objects this mostly is to recharge them
-- By default, does nothing at all
function _M:act()
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
function _M:stack(o)
	if not self:canStack(o) then return false end
	self.stacked = self.stacked or {}
	self.stacked[#self.stacked+1] = o

	-- Merge stacks
	if o.stacked then
		for i, so in ipairs(o.stacked) do
			self.stacked[#self.stacked+1] = so
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

	local str = "Requires:\n"

	if req.stat then
		for s, v in pairs(req.stat) do
			local c = (who:getStat(s) >= v) and "#00ff00#" or "#ff0000#"
			str = str .. ("- %s%s %d\n"):format(c, who.stats_def[s].name, v)
		end
	end
	if req.level then
		local c = (who.level >= req.level) and "#00ff00#" or "#ff0000#"
		str = str .. ("- %sLevel %d\n"):format(c, req.level)
	end
	if req.talent then
		for _, tid in ipairs(req.talent) do
			local c = who:knowTalent(tid) and "#00ff00#" or "#ff0000#"
			str = str .. ("- %sTalent %s\n"):format(c, who:getTalentFromId(tid).name)
		end
	end
	return str
end
