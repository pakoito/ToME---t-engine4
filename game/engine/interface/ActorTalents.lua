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
	t.talents = {}
	table.insert(self.talents_types_def, t)
	self.talents_types_def[t.type] = t
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
	t.id = #self.talents_def
	self["T_"..t.short_name] = #self.talents_def

	-- Register in the type
	table.insert(self.talents_types_def[t.type[1]].talents, t)
end

--- Initialises stats with default values if needed
function _M:init(t)
	self.talents = t.talents or {}
	self.talents_types = t.talents_types or {}
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

--- Replace some markers in a string with info on the talent
function _M:useTalentMessage(ab)
	local str = ab.message
	str = str:gsub("@Source@", self.name:capitalize())
	str = str:gsub("@source@", self.name)
	return str
end

--- Called before an talent is used
-- Redefine as needed
-- @param ab the talent (not the id, the table)
-- @return true to continue, false to stop
function _M:preUseTalent(talent)
	return true
end

--- Called before an talent is used
-- Redefine as needed
-- @param ab the talent (not the id, the table)
-- @param ret the return of the talent action
-- @return true to continue, false to stop
function _M:postUseTalent(talent, ret)
	return true
end

--- Returns how many talents of this type the actor knows
function _M:numberKnownTalent(type)
	local nb = 0
	for id, _ in pairs(self.talents) do
		local t = _M.talents_def[id]
		if t.type[1] == type then nb = nb + 1 end
	end
	return nb
end

--- Actor learns a talent
-- @param t_id the id of the talent to learn
-- @return true if the talent was learnt, nil and an error message otherwise
function _M:learnTalent(t_id)
	local t = _M.talents_def[t_id]

	local ok, err = self:canLearnTalent(t)
	if not ok and err then return nil, err end

	self.talents[t_id] = true
	return true
end

function _M:canLearnTalent(t)
	-- Check prerequisites
	if t.require then
		-- Obviously this requires the ActorStats interface
		if t.require.stat then
			for s, v in pairs(t.require.stat) do
				if self:getStat(s) < v then return nil, "not enough stat" end
			end
		end
		if t.require.level and self.level < t.require.level then
			return nil, "not enough levels"
		end
	end

	-- Check talent type
	local known = self:numberKnownTalent(t.type[1])
	if known < t.type[1] - 1 then
		return nil, "not enough talents of this type known"
	end

	-- Ok!
	return true
end

--- Do we know this talent type
function _M:knowTalentType(t)
	return self.talents_types[t]
end

--- Do we know this talent
function _M:knowTalent(t)
	return self.talents[t]
end
