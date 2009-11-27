require "engine.class"

--- Handles actors stats
module(..., package.seeall, class.make)

_M.abilities_def = {}
_M.abilities_types_def = {}

--- Defines actor abilities
-- Static!
function _M:loadDefinition(file)
	local f = loadfile(file)
	setfenv(f, {
		newAbility = function(t) self:newAbility(t) end,
		newAbilityType = function(t) self:newAbilityType(t) end,
	})
	f()
end

--- Defines one ability type(group)
-- Static!
function _M:newAbilityType(t)
	assert(t.name, "no ability type name")
	assert(t.type, "no ability type type")
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
end

--- Initialises stats with default values if needed
function _M:init(t)
	self.abilities = t.abilities or {}
end
