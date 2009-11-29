require "engine.class"

--- Handles actors stats
module(..., package.seeall, class.make)

_M.talents_def = {}
_M.talents_types_def = {}

--- Defines actor talents
-- Static!
function _M:loadDefinition(file)
	local f = loadfile(file)
	setfenv(f, setmetatable({
		DamageType = require("engine.DamageType"),
		newTalent = function(t) self:newTalent(t) end,
		newTalentType = function(t) self:newTalentType(t) end,
	}, {__index=_G}))
	f()
end

--- Defines one talent type(group)
-- Static!
function _M:newTalentType(t)
	assert(t.name, "no talent type name")
	assert(t.type, "no talent type type")

	table.insert(self.talents_types_def, t)
end

--- Defines one talent
-- Static!
function _M:newTalent(t)
	assert(t.name, "no talent name")
	assert(t.type, "no or unknown talent type")
	t.short_name = t.short_name or t.name
	t.short_name = t.short_name:upper():gsub("[ ]", "_")
	t.mana = t.mana or 0
	t.stamina = t.stamina or 0
	t.mode = t.mode or "activated"
	assert(t.mode == "activated" or t.mode == "sustained", "wrong talent mode, requires either 'activated' or 'sustained'")
	assert(t.info, "no talent info")

	table.insert(self.talents_def, t)
	self["T_"..t.short_name] = #self.talents_def
end

--- Initialises stats with default values if needed
function _M:init(t)
	self.talents = t.talents or {}
end

--- Make the actor use the talent
function _M:useTalent(id)
	local ab = _M.talents_def[id]
	assert(ab, "trying to cast talent "..tostring(id).." but it is not defined")

	if ab.action then
		if not self:preUseTalent(ab) then return end
		local co = coroutine.create(function()
			local ret = ab.action(self)

			if not self:postUseTalent(ab, ret) then return end
		end)
		local ok, err = coroutine.resume(co)
		if not ok and err then error(err) end
	end
end

--- Called before an talent is used
-- Redefine as needed
-- @param ab the talent (not the id, the table)
-- @return true to continue, false to stop
function _M:preUseTalent(ab)
	return true
end

--- Called before an talent is used
-- Redefine as needed
-- @param ab the talent (not the id, the table)
-- @param ret the return of the talent action
-- @return true to continue, false to stop
function _M:postUseTalent(ab, ret)
	return true
end
