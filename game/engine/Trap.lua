require "engine.class"
local Entity = require "engine.Entity"

--- Describes a trap
module(..., package.seeall, class.inherit(Entity))

function _M:init(t, no_default)
	t = t or {}

	assert(t.triggered, "no trap triggered action")

	Entity.init(self, t, no_default)

	if self.disarmable == nil then
		self.disarmable = true
	end

	self.known_by = {}
	self:loaded()
end

function _M:loaded()
	-- known_by table is a weak table on keys, so taht it does not prevent garbage collection of actors
	setmetatable(self.known_by, {__mode="k"})
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
	print("actor", actor.name, "knows", self.name)
	return self.known_by[actor]
end

--- Try to disarm the trap
function _M:disarm(x, y, who)
	if not self.disarmable then return false end
end

--- Trigger the trap
function _M:trigger(x, y, who)
	if not self.message then
		game.logSeen(who, "%s triggers a trap (%s)!", who.name:capitalize(), self.name)
	else
		local tname = who.name
		local str =self.message
		str = str:gsub("@target@", tname)
		str = str:gsub("@Target@", tname:capitalize())
		game.logSeen(who, "%s", str)
	end
	if self:triggered(x, y, who) then
		self:knownBy(who, true)
		game.level.map:updateMap(x, y)
	end
end

--- When moving on a trap, trigger it
function _M:on_move(x, y, who)
	self:trigger(x, y, who)
end

--[=[
require "engine.class"
local Entity = require "engine.Entity"

--- Describes a trap
module(..., package.seeall, class.inherit(Entity))

function _M:init(t, no_default)
	t = t or {}

	assert(t.triggered, "no trap triggered action")

	Entity.init(self, t, no_default)

	if self.disarmable == nil then
		self.disarmable = true
	end

	self.known_by_list = {}
	self:loaded()
end

function _M:loaded()
	-- known_by table is a weak table on keys, so taht it does not prevent garbage collection of actors
	self.known_by = {}
	setmetatable(self.known_by, {__mode="k"})
	setmetatable(self.known_by_list, {__mode="v"})

	-- Restore
	for i, a in ipairs(self.known_by_list) self.known_by[a] = true end
end

--- Setup the trap
function _M:setup()
end

--- Set the known status for the given actor
function _M:setKnown(actor)
	print("actor", actor.name, "knows", self.name)
	if not self.known_by[actor] then
		self.known_by[actor] = true
		table.insert(self.known_by_list, actor)
	end
end

--- Get the known status for the given actor
function _M:knownBy(actor)
	return self.known_by[actor]
end

--- Try to disarm the trap
function _M:disarm(x, y, who)
	if not self.disarmable then return false end
end

--- Trigger the trap
function _M:trigger(x, y, who)
	if not self.message then
		game.logSeen(who, "%s triggers a trap (%s)!", who.name:capitalize(), self.name)
	else
		local tname = who.name
		local str =self.message
		str = str:gsub("@target@", tname)
		str = str:gsub("@Target@", tname:capitalize())
		game.logSeen(who, "%s", str)
	end
	if self:triggered(x, y, who) then
		self.known_by[who.uid] = true
		game.level.map:updateMap(x, y)
	end
end

--- When moving on a trap, trigger it
function _M:on_move(x, y, who)
	self:trigger(x, y, who)
end

--]=]