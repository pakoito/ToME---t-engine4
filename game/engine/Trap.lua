require "engine.class"
local Entity = require "engine.Entity"
local Map = require "engine.Map"

--- Describes a trap
module(..., package.seeall, class.inherit(Entity))

function _M:init(t, no_default)
	t = t or {}

	assert(t.triggered, "no trap triggered action")

	Entity.init(self, t, no_default)

	if self.disarmable == nil then
		self.disarmable = true
	end

	self.detect_power = self.detect_power or 1
	self.disarm_power = self.disarm_power or 1

	self.known_by = {}
	self:loaded()
end

function _M:loaded()
	-- known_by table is a weak table on keys, so taht it does not prevent garbage collection of actors
	setmetatable(self.known_by, {__mode="k"})
end

--- Get trap name
-- Can be overloaded to do trap identification if needed
function _M:getName()
	return self.name
end

--- Setup the trap
function _M:setup()
end

--- Set the known status for the given actor
function _M:setKnown(actor, v)
	self.known_by[actor] = v
end

--- Get the known status for the given actor
function _M:knownBy(actor)
	return self.known_by[actor]
end

--- Can we disarm this trap?
function _M:canDisarm(x, y, who)
	if not self.disarmable then return false end
	return true
end

--- Try to disarm the trap
function _M:disarm(x, y, who)
	if not self:canDisarm(x, y, who) then
		game.logSeen(who, "%s fails to disarm a trap (%s).", who.name:capitalize(), self:getName())
		return false
	end
	game.level.map:remove(x, y, Map.TRAP)
	if self.removed then
		self:removed(x, y, who)
	end
	game.logSeen(who, "%s disarms a trap (%s).", who.name:capitalize(), self:getName())
	self:onDisarm(x, y, who)
	return true
end

--- Trigger the trap
function _M:trigger(x, y, who)
	-- Try to disarm
	if self:knownBy(who) then
		-- Try to disarm
		if self:disarm(x, y, who) then
			return
		end
	end

	if not self.message then
		game.logSeen(who, "%s triggers a trap (%s)!", who.name:capitalize(), self:getName())
	else
		local tname = who.name
		local str =self.message
		str = str:gsub("@target@", tname)
		str = str:gsub("@Target@", tname:capitalize())
		game.logSeen(who, "%s", str)
	end
	if self:triggered(x, y, who) then
		self:setKnown(who, true)
		game.level.map:updateMap(x, y)
	end
end

--- When moving on a trap, trigger it
function _M:on_move(x, y, who, forced)
	if not forced then self:trigger(x, y, who) end
end

--- Called when disarmed
function _M:onDisarm(x, y, who)
end
