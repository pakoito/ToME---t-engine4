require "engine.class"

--- Handles actors stats
module(..., package.seeall, class.make)

_M.abilities_def = {}
_M.abilities_types_def = {}

--- Defines actor abilities
-- Static!
function _M:loadDefinition(file)
	local f = loadfile(file)
	setfenv(f, setmetatable({
		DamageType = require("engine.DamageType"),
		newAbility = function(t) self:newAbility(t) end,
		newAbilityType = function(t) self:newAbilityType(t) end,
	}, {__index=_G}))
	f()
end

--- Defines one ability type(group)
-- Static!
function _M:newAbilityType(t)
	assert(t.name, "no ability type name")
	assert(t.type, "no ability type type")

	table.insert(self.abilities_types_def, t)
end

--- Defines one ability
-- Static!
function _M:newAbility(t)
	assert(t.name, "no ability name")
	assert(t.type, "no or unknown ability type")
	t.short_name = t.short_name or t.name
	t.short_name = t.short_name:upper():gsub("[ ]", "_")
	t.mana = t.mana or 0
	t.stamina = t.stamina or 0
	t.mode = t.mode or "activated"
	assert(t.mode == "activated" or t.mode == "sustained", "wrong ability mode, requires either 'activated' or 'sustained'")
	assert(t.info, "no ability info")

	table.insert(self.abilities_def, t)
	self["AB_"..t.short_name] = #self.abilities_def
end

--- Initialises stats with default values if needed
function _M:init(t)
	self.abilities = t.abilities or {}
end

--- Make the actor use the ability
function _M:useAbility(id)
	local ab = _M.abilities_def[id]
	assert(ab, "trying to cast ability "..tostring(id).." but it is not defined")

	if ab.action then
		if not self:preUseAbility(ab) then return end
		local co = coroutine.create(function()
			local ret = ab.action(self)

			if not self:postUseAbility(ab, ret) then return end
		end)
		local ok, err = coroutine.resume(co)
		if not ok and err then error(err) end
	end
end

--- Called before an ability is used
-- Redefine as needed
-- @param ab the ability (not the id, the table)
-- @return true to continue, false to stop
function _M:preUseAbility(ab)
	return true
end

--- Called before an ability is used
-- Redefine as needed
-- @param ab the ability (not the id, the table)
-- @param ret the return of the ability action
-- @return true to continue, false to stop
function _M:postUseAbility(ab, ret)
	return true
end
