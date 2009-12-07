require "engine.class"

--- Handles actors stats
module(..., package.seeall, class.make)

_M.talents_def = {}
_M.talents_types_def = {}

--- Defines actor talents
-- Static!
function _M:loadDefinition(file)
	local f, err = loadfile(file)
	if not f and err then error(err) end
	setfenv(f, setmetatable({
		DamageType = require("engine.DamageType"),
		newTalent = function(t) self:newTalent(t) end,
		newTalentType = function(t) self:newTalentType(t) end,
		load = function(f) self:loadDefinition(f) end
	}, {__index=_G}))
	f()
end

--- Defines one talent type(group)
-- Static!
function _M:newTalentType(t)
	assert(t.name, "no talent type name")
	assert(t.type, "no talent type type")
	t.description = t.description or ""
	t.points = t.points or 1
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
	t.mode = t.mode or "activated"
	t.points = t.points or 1
	assert(t.mode == "activated" or t.mode == "sustained" or t.mode == "passive", "wrong talent mode, requires either 'activated' or 'sustained'")
	assert(t.info, "no talent info")

	-- Can pass a string, make it into a function
	if type(t.info) == "string" then
		local infostr = t.info
		t.info = function() return infostr end
	end
	-- Remove line stat with tabs to be cleaner ..
	local info = t.info
	t.info = function(self) return info(self):gsub("\n\t+", "\n") end

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
	self.talents_cd = {}
	self.sustain_talents = {}
end

--- Make the actor use the talent
function _M:useTalent(id)
	local ab = _M.talents_def[id]
	assert(ab, "trying to cast talent "..tostring(id).." but it is not defined")

	if ab.mode == "activated" and ab.action then
		if self:isTalentCoolingDown(ab) then
			game.logPlayer(self, "%s is still on cooldown for %d turns.", ab.name:capitalize(), self.talents_cd[ab.id])
			return
		end
		if not self:preUseTalent(ab) then return end
		local co = coroutine.create(function()
			local ret = ab.action(self)

			if not self:postUseTalent(ab, ret) then return end

			-- Everything went ok? then start cooldown if any
			self:startTalentCooldown(ab)
		end)
		local ok, err = coroutine.resume(co)
		if not ok and err then error(err) end
	elseif ab.mode == "sustained" and ab.activate and ab.deactivate then
		if self:isTalentCoolingDown(ab) then
			game.logPlayer(self, "%s is still on cooldown for %d turns.", ab.name:capitalize(), self.talents_cd[ab.id])
			return
		end
		if not self:preUseTalent(ab) then return end
		local co = coroutine.create(function()
			if not self.sustain_talents[id] then
				local ret = ab.activate(self)

				if not self:postUseTalent(ab, ret) then return end

				self.sustain_talents[id] = ret
			else
				local ret = ab.deactivate(self, self.sustain_talents[id])

				if not self:postUseTalent(ab, ret) then return end

				-- Everything went ok? then start cooldown if any
				self:startTalentCooldown(ab)
				self.sustain_talents[id] = nil
			end
		end)
		local ret, err = coroutine.resume(co)
		if not ret and err then error(err) end
	else
		error("Activating non activable or sustainable talent: "..id.." :: "..ab.name.." :: "..ab.mode)
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

--- Is the sustained talent activated ?
function _M:isTalentActive(t_id)
	return self.sustain_talents[t_id]
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
function _M:learnTalent(t_id, force)
	local t = _M.talents_def[t_id]

	if not force then
		local ok, err = self:canLearnTalent(t)
		if not ok and err then return nil, err end
	end

	-- Auto assign to hotkey
	if t.mode ~= "passive" then
		for i = 1, 12 do
			if not self.hotkey[i] then
				self.hotkey[i] = t_id
				break
			end
		end
	end

	self.talents[t_id] = true
	self.changed = true
	return true
end

--- Actor forgets a talent
-- @param t_id the id of the talent to learn
-- @return true if the talent was unlearnt, nil and an error message otherwise
function _M:unlearnTalent(t_id)
	for i, known_t_id in pairs(self.hotkey) do
		if known_t_id == t_id then self.hotkey[i] = nil end
	end
	self.talents[t_id] = nil
	self.changed = true
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
	if t.type[2] and known < t.type[2] - 1 then
		return nil, "not enough talents of this type known"
	end

	-- Ok!
	return true
end

--- Formats the requirements as a (multiline) string
-- @param t_id the id of the talent to desc
function _M:getTalentReqDesc(t_id)
	local t = _M.talents_def[t_id]
	local req = t.require
	if not req then return "" end

	local str = ""

	if t.type[2] and t.type[2] > 1 then
		local known = self:numberKnownTalent(t.type[1])
		local c = (known >= t.type[2] - 1) and "#00ff00#" or "#ff0000#"
		str = str .. ("- %sTalents of the same category: %d\n"):format(c, t.type[2] - 1)
	end

	-- Obviously this requires the ActorStats interface
	if req.stat then
		for s, v in pairs(req.stat) do
			local c = (self:getStat(s) >= v) and "#00ff00#" or "#ff0000#"
			str = str .. ("- %s%s %d\n"):format(c, self.stats_def[s].name, v)
		end
	end
	if req.level then
		local c = (self.level >= req.level) and "#00ff00#" or "#ff0000#"
		str = str .. ("- %sLevel %d\n"):format(c, req.level)
	end

	return str
end

--- Do we know this talent type
function _M:knowTalentType(name)
	return self.talents_types[name]
end

--- Do we know this talent
function _M:knowTalent(id)
	return self.talents[id] and true or false
end

--- Return talent definition from id
function _M:getTalentFromId(id)
	return _M.talents_def[id]
end

--- Return talent definition from id
function _M:getTalentTypeFrom(id)
	return _M.talents_types_def[id]
end

--- Actor learns a talent type
-- @param t_id the id of the talent to learn
-- @return true if the talent was learnt, nil and an error message otherwise
function _M:learnTalentType(tt, v)
	if v == nil then v = true end
	self.talents_types[tt] = v
	self.changed = true
	return true
end

--- Actor forgets a talent type
-- @param t_id the id of the talent to learn
-- @return true if the talent was unlearnt, nil and an error message otherwise
function _M:unlearnTalentType(tt)
	self.talents_types[tt] = false
	self.changed = true
	return true
end

--- Starts a talent cooldown
-- @param t the talent to cooldown
function _M:startTalentCooldown(t)
	if not t.cooldown then return end
	self.talents_cd[t.id] = t.cooldown
	self.changed = true
end

--- Is talent in cooldown?
function _M:isTalentCoolingDown(t)
	if not t.cooldown then return false end
	if self.talents_cd[t.id] and self.talents_cd[t.id] > 0 then return self.talents_cd[t.id] else return false end
end

--- Cooldown all talents by one
-- This should be called in your actors "act()" method
function _M:cooldownTalents()
	for tid, c in pairs(self.talents_cd) do
		self.changed = true
		self.talents_cd[tid] = self.talents_cd[tid] - 1
		if self.talents_cd[tid] == 0 then
			self.talents_cd[tid] = nil
			if self.onTalentCooledDown then self:onTalentCooledDown(tid) end
		end
	end
end

--- Show usage dialog
function _M:useTalents()
	local d = require("engine.dialogs.UseTalents").new(self)
	-- Load the locales
	d.key:loadLocaleConvertion("/data/locales/number_hotkey.lua")
	game:registerDialog(d)
end
