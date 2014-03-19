-- TE4 - T-Engine 4
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

_M.stats_def = {}

--- Defines stats
-- Static!
function _M:defineStat(name, short_name, default_value, min, max, desc)
	assert(name, "no stat name")
	assert(short_name, "no stat short_name")
	local no_max = false
	if type(max) == "table" then no_max = max.no_max; max = max[1] end
	table.insert(self.stats_def, {
		name = name,
		short_name = short_name,
		description = desc,
		def = default_value or 10,
		min = min or 1,
		max = max or 100,
		no_max = no_max,
	})
	self.stats_def[#self.stats_def].id = #self.stats_def
	self.stats_def[short_name] = self.stats_def[#self.stats_def]
	self["STAT_"..short_name:upper()] = #self.stats_def
	self["get"..short_name:lower():capitalize()] = function(self, scale, raw, no_inc)
		return self:getStat(_M["STAT_"..short_name:upper()], scale, raw, no_inc)
	end
end

--- Initialises stats with default values if needed
function _M:init(t)
	self.stats = t.stats or {}
	self.inc_stats = t.inc_stats or {}
	for i, s in ipairs(_M.stats_def) do
		if self.stats[i] then
		elseif self.stats[s.short_name] then
			self.stats[i] = self.stats[s.short_name]
			self.stats[s.short_name] = nil
		else
			self.stats[i] = s.def
		end

		if self.inc_stats[i] then
		elseif self.inc_stats[s.short_name] then
			self.inc_stats[i] = self.inc_stats[s.short_name]
			self.inc_stats[s.short_name] = nil
		else
			self.inc_stats[i] = 0
		end
	end
end

--- Increases a stat
-- @param stat the stat id to change
-- @param val the increment to add/subtract
function _M:incStat(stat, val)
	if type(stat) == "string" then
		stat = _M.stats_def[stat].id
	end

	local old = self:getStat(stat)
	if _M.stats_def[stat].no_max then
		self.stats[stat] = math.max(self.stats[stat] + val, _M.stats_def[stat].min)
	else
		self.stats[stat] = math.max(math.min(self.stats[stat] + val, _M.stats_def[stat].max), _M.stats_def[stat].min)
	end
	if self:getStat(stat) ~= old then
		self:onStatChange(stat, self:getStat(stat) - old)
	end
	self.changed = true
	return self:getStat(stat) - old
end

--- Increases a stat additional value
-- @param stat the stat id to change
-- @param val the increment to add/subtract
function _M:incIncStat(stat, val)
	if type(stat) == "string" then
		stat = _M.stats_def[stat].id
	end

	local old = self:getStat(stat)
	self.inc_stats[stat] = self.inc_stats[stat] + val
	if self:getStat(stat) ~= old then
		self:onStatChange(stat, self:getStat(stat) - old)
	end
	self.changed = true
	return self:getStat(stat) - old
end

--- Gets a stat value
-- Not that the engine also auto-defines stat specific methods on the form: self:getShortname().
-- If you stat short name is STR then it becomes getStr()
-- @param stat the stat id
-- @param scale a scaling factor, nil means max stat value
-- @param raw false if the scaled result must be rounded down
-- @param no_inc if true it wont include stats gained by self.inc_stats
function _M:getStat(stat, scale, raw, no_inc)
	local val, inc
	if type(stat) == "string" then
		val = self.stats[_M.stats_def[stat].id]
		inc = self.inc_stats[_M.stats_def[stat].id]
	else
		val = self.stats[stat]
		inc = self.inc_stats[stat]
	end
	if _M.stats_def[stat].no_max then
		val = math.max(val + ((not no_inc) and inc or 0), _M.stats_def[stat].min)
	else
		val = math.max(util.bound(val, _M.stats_def[stat].min, _M.stats_def[stat].max) + ((not no_inc) and inc or 0), _M.stats_def[stat].min)
	end
	if scale then
		if not raw then
			val = math.floor(val * scale / _M.stats_def[stat].max)
		else
			val = val * scale / _M.stats_def[stat].max
		end
	end
	return val
end

--- Is the stat maxed ?
function _M:isStatMax(stat)
	local val
	if type(stat) == "string" then
		val = self.stats[_M.stats_def[stat].id]
	else
		val = self.stats[stat]
	end
	if math.floor(val) >= _M.stats_def[stat].max then return true end
end

--- Notifies a change of stat value
function _M:onStatChange(stat, v)
end
