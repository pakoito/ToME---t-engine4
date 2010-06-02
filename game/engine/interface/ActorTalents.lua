-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

require "engine.class"

--- Handles actors stats
module(..., package.seeall, class.make)

_M.talents_def = {}
_M.talents_types_def = {}

--- Defines actor talents
-- Static!
function _M:loadDefinition(file, env)
	local f, err = loadfile(file)
	if not f and err then error(err) end
	setfenv(f, setmetatable(env or {
		DamageType = require("engine.DamageType"),
		Particles = require("engine.Particles"),
		Talents = self,
		Map = require("engine.Map"),
		newTalent = function(t) self:newTalent(t) end,
		newTalentType = function(t) self:newTalentType(t) end,
		load = function(f) self:loadDefinition(f, getfenv(2)) end
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
	if type(t.type) == "string" then t.type = {t.type, 1} end
	if not t.type[2] then t.type[2] = 1 end
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
	t.info = function(self, t) return info(self, t):gsub("\n\t+", "\n") end

	table.insert(self.talents_def, t)
	t.id = #self.talents_def
	self["T_"..t.short_name] = #self.talents_def
	print("[TALENT]", t.name, t.short_name, #self.talents_def)

	-- Register in the type
	table.insert(self.talents_types_def[t.type[1]].talents, t)
end

--- Initialises stats with default values if needed
function _M:init(t)
	self.talents = t.talents or {}
	self.talents_types = t.talents_types or {}
	self.talents_types_mastery = {}
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
			print("USING", ab, ab.name)
			local ret = ab.action(self, ab)

			if not self:postUseTalent(ab, ret) then return end

			-- Everything went ok? then start cooldown if any
			self:startTalentCooldown(ab)
		end)
		local ok, err = coroutine.resume(co)
		if not ok and err then print(debug.traceback(co)) error(err) end
	elseif ab.mode == "sustained" and ab.activate and ab.deactivate then
		if self:isTalentCoolingDown(ab) then
			game.logPlayer(self, "%s is still on cooldown for %d turns.", ab.name:capitalize(), self.talents_cd[ab.id])
			return
		end
		if not self:preUseTalent(ab) then return end
		local co = coroutine.create(function()
			if not self.sustain_talents[id] then
				local ret = ab.activate(self, ab)

				if not self:postUseTalent(ab, ret) then return end

				self.sustain_talents[id] = ret
			else
				local ret = ab.deactivate(self, ab, self.sustain_talents[id])

				if not self:postUseTalent(ab, ret) then return end

				-- Everything went ok? then start cooldown if any
				self:startTalentCooldown(ab)
				self.sustain_talents[id] = nil
			end
		end)
		local ret, err = coroutine.resume(co)
		if not ret and err then print(debug.traceback(co)) error(err) end
	else
		error("Activating non activable or sustainable talent: "..id.." :: "..ab.name.." :: "..ab.mode)
	end
	self.changed = true
	return true
end

--- Replace some markers in a string with info on the talent
function _M:useTalentMessage(ab)
	if not ab.message then return nil end
	local str = ab.message
	local _, _, target = self:getTarget()
	local tname = "unknown"
	if target then tname = target.name end
	str = str:gsub("@Source@", self.name:capitalize())
	str = str:gsub("@source@", self.name)
	str = str:gsub("@target@", tname)
	str = str:gsub("@Target@", tname:capitalize())
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
-- @param type the talent type to count
-- @param exlude_id if not nil the count will ignore this talent id
function _M:numberKnownTalent(type, exlude_id)
	local nb = 0
	for id, _ in pairs(self.talents) do
		local t = _M.talents_def[id]
		if t.type[1] == type and (not exlude_id or exlude_id ~= id) then nb = nb + 1 end
	end
	return nb
end

--- Actor learns a talent
-- @param t_id the id of the talent to learn
-- @return true if the talent was learnt, nil and an error message otherwise
function _M:learnTalent(t_id, force, nb)
	local t = _M.talents_def[t_id]

	if not force then
		local ok, err = self:canLearnTalent(t)
		if not ok and err then return nil, err end
	end

	if not self.talents[t_id] then
		-- Auto assign to hotkey
		if t.mode ~= "passive" and self.hotkey then
			for i = 1, 36 do
				if not self.hotkey[i] then
					self.hotkey[i] = {"talent", t_id}
					break
				end
			end
		end
	end

	self.talents[t_id] = (self.talents[t_id] or 0) + (nb or 1)

	if t.on_learn then t.on_learn(self, t) end

	self.changed = true
	return true
end

--- Actor forgets a talent
-- @param t_id the id of the talent to learn
-- @return true if the talent was unlearnt, nil and an error message otherwise
function _M:unlearnTalent(t_id)
	local t = _M.talents_def[t_id]

	if self.talents[t_id] and self.talents[t_id] == 1 then
		if self.hotkey then
			for i, known_t_id in pairs(self.hotkey) do
				if known_t_id[1] == "talent" and known_t_id[2] == t_id then self.hotkey[i] = nil end
			end
		end
	end

	self.talents[t_id] = self.talents[t_id] - 1
	if self.talents[t_id] == 0 then self.talents[t_id] = nil end

	if t.on_unlearn then t.on_unlearn(self, t) end

	self.changed = true
	return true
end

--- Checks the talent if learnable
-- @param t the talent to check
-- @param offset the level offset to check, defaults to 1
function _M:canLearnTalent(t, offset)
	-- Check prerequisites
	if t.require then
		local req = t.require
		if type(req) == "function" then req = req(self, t) end
		local tlev = self:getTalentLevelRaw(t) + (offset or 1)

		-- Obviously this requires the ActorStats interface
		if req.stat then
			for s, v in pairs(req.stat) do
				v = util.getval(v, tlev)
				if self:getStat(s) < v then return nil, "not enough stat" end
			end
		end
		if req.level then
			if self.level < util.getval(req.level, tlev) then
				return nil, "not enough levels"
			end
		end
		if req.talent then
			for _, tid in ipairs(req.talent) do
				if type(tid) == "table" then
					if self:getTalentLevelRaw(tid[1]) < tid[2] then return nil, "missing dependency" end
				else
					if not self:knowTalent(tid) then return nil, "missing dependency" end
				end
			end
		end
	end

	if not self:knowTalentType(t.type[1]) and not t.type_no_req then return nil, "unknown talent type" end

	-- Check talent type
	local known = self:numberKnownTalent(t.type[1], t.id)
	if t.type[2] and known < t.type[2] - 1 then
		return nil, "not enough talents of this type known"
	end

	-- Ok!
	return true
end

--- Formats the requirements as a (multiline) string
-- @param t_id the id of the talent to desc
-- @param levmod a number (1 should be the smartest) to add to current talent level to display requirements, defaults to 0
function _M:getTalentReqDesc(t_id, levmod)
	local t = _M.talents_def[t_id]
	local req = t.require
	if not req then return "" end
	if type(req) == "function" then req = req(self, t) end

	local tlev = self:getTalentLevelRaw(t_id) + (levmod or 0)

	local str = ""

	if not t.type_no_req then
		str = str .. (self:knowTalentType(t.type[1]) and "#00ff00#" or "#ff0000#") .. "- Talent category known\n"
	end

	if t.type[2] and t.type[2] > 1 then
		local known = self:numberKnownTalent(t.type[1], t.id)
		local c = (known >= t.type[2] - 1) and "#00ff00#" or "#ff0000#"
		str = str .. ("- %sTalents of the same category: %d\n"):format(c, t.type[2] - 1)
	end

	-- Obviously this requires the ActorStats interface
	if req.stat then
		for s, v in pairs(req.stat) do
			v = util.getval(v, tlev)
			local c = (self:getStat(s) >= v) and "#00ff00#" or "#ff0000#"
			str = str .. ("- %s%s %d\n"):format(c, self.stats_def[s].name, v)
		end
	end
	if req.level then
		local v = util.getval(req.level, tlev)
		local c = (self.level >= v) and "#00ff00#" or "#ff0000#"
		str = str .. ("- %sLevel %d\n"):format(c, v)
	end
	if req.talent then
		for _, tid in ipairs(req.talent) do
			if type(tid) == "table" then
				local c = (self:getTalentLevelRaw(tid[1]) >= tid[2]) and "#00ff00#" or "#ff0000#"
				str = str .. ("- %sTalent %s (%d)\n"):format(c, self:getTalentFromId(tid[1]).name, tid[2])
			else
				local c = self:knowTalent(tid) and "#00ff00#" or "#ff0000#"
				str = str .. ("- %sTalent %s\n"):format(c, self:getTalentFromId(tid).name)
			end
		end
	end

	return str
end

--- Return the full description of a talent
-- You may overload it to add more data (like power usage, ...)
function _M:getTalentFullDescription(t)
	return t.info(self, t)
end

--- Do we know this talent type
function _M:knowTalentType(name)
	return self.talents_types[name]
end

--- Do we know this talent
function _M:knowTalent(id)
	if type(id) == "table" then id = id.id end
	return self.talents[id] and true or false
end

--- Talent level, 0 if not known
function _M:getTalentLevelRaw(id)
	if type(id) == "table" then id = id.id end
	return self.talents[id] or 0
end

--- Talent level, 0 if not known
-- Includes mastery
function _M:getTalentLevel(id)
	local t

	if type(id) == "table" then
		t, id = id, id.id
	else
		t = _M.talents_def[id]
	end
	return (self.talents[id] or 0) * (self.talents_types_mastery[t.type[1]] or 1)
end

--- Talent type level, sum of all raw levels of talents inside
function _M:getTalentTypeLevelRaw(tt)
	local nb = 0
	for tid, lev in pairs(self.talents) do
		local t = self:getTalentFromId(tid)
		if t.type[1] == tt then nb = nb + lev end
	end
	return nb
end

--- Return talent definition from id
function _M:getTalentTypeMastery(tt)
	return self.talents_types_mastery[tt] or 1
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
	if self.talents_types[tt] then return end
	self.talents_types[tt] = v
	self.talents_types_mastery[tt] = self.talents_types_mastery[tt] or 1
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

--- Returns the range of a talent
function _M:getTalentRange(t)
	if not t.range then return 1 end
	if type(t.range) == "function" then return t.range(self, t) end
	return t.range
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
	game:registerDialog(d)
end
