require "engine.class"
require "engine.Trap"
require "engine.interface.ObjectIdentify"

module(..., package.seeall, class.inherit(
	engine.Trap,
	engine.interface.ObjectIdentify
))

function _M:init(t, no_default)
	engine.Trap.init(self, t, no_default)
	engine.interface.ObjectIdentify.init(self, t)
end

--- Gets the full name of the object
function _M:getName()
	local name = self.name
	if not self:isIdentified() and self:getUnidentifiedName() then name = self:getUnidentifiedName() end
	return name
end

--- Returns a tooltip for the trap
function _M:tooltip()
	if self:knownBy(game.player) then
		return self:getName()
	end
end

--- Can we disarm this trap?
function _M:canDisarm(x, y, who)
	if not engine.Trap.canDisarm(self, x, y, who) then return false end

	-- do we know how to disarm?
	if who:knowTalent(who.T_TRAP_DISARM) then
		local power = who:getTalentLevel(who.T_TRAP_DISARM) * who:getCun(25)
		if who:checkHit(power, self.disarm_power) then
			return true
		end
	end

	-- False by default
	return false
end
