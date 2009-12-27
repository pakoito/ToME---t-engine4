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
	engine.Entity.resolve(self, t)

	if not t then
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
