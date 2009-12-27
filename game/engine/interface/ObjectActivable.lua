require "engine.class"

--- Handles activable objects, much more simple than actor's resource
module(..., package.seeall, class.make)

function _M:init(t)
	if t.max_power then
		self.power = t.max_power
		self.max_power = t.max_power
		self.power_regen = t.power_regen or 0
	end
end

--- Regen resources, shout be called in your actor's act() method
function _M:regenPower()
	self.power = util.bound(self.power + self.power_regen, 0, self.max_power)
end

function _M:canUseObject()
	if self.use_simple or self.use_power then
		return true
	end
end

function _M:getUseDesc()
	if self.use_power then
		return ("It can be used to %s, costing %d power out of %d/%d."):format(self.use_power.name, self.use_power.power, self.power, self.max_power)
	elseif self.use_simple then
		return ("It can be used to %s."):format(self.use_simple.name)
	end
end

function _M:useObject(who)
	if self.use_power then
		if self.power >= self.use_power.power then
			local ret, no_power = self.use_power.use(self, who)
			if not no_power then self.power = self.power - self.use_power.power end
			return ret
		end
	elseif self.use_simple then
		local ret = self.use_simple.use(self, who)
		return ret
	end
end
