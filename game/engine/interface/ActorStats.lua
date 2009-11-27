require "engine.class"

--- Handles actors stats
module(..., package.seeall, class.make)

_M.stats_def = {}

--- Defines stats
-- Static!
function _M:defineStat(name, short_name, default_value, min, max)
	assert(name, "no stat name")
	assert(short_name, "no stat short_name")
	table.insert(self.stats_def, {
		name = name,
		short_name = short_name,
		def = default_value or 10,
		min = min or 1,
		max = max or 100,
	})
	self.stats_def[short_name] = self.stats_def[#self.stats_def]
	self["STAT_"..short_name:upper()] = #self.stats_def
	self["get"..short_name:lower():capitalize()] = function(self, scale)
		local val = self.stats[_M["STAT_"..short_name:upper()]]
		if scale then
			val = math.floor(val * scale / max)
		end
		return val
	end
end

--- Initialises stats with default values if needed
function _M:init(t)
	self.stats = t.stats or {}
	for i, s in ipairs(_M.stats_def) do
		if self.stats[i] then
		elseif self.stats[s.short_name] then
			self.stats[i] = self.stats[s.short_name]
			self.stats[s.short_name] = nil
		else
			self.stats[i] = s.def
		end
	end
end

---
-- Module authors should rewrite it to handle combat, dialog, ...
-- @param target the actor attacking us
function _M:incStat(stat, val)
	self.stats[stat] = max(min(val, _M.stats_def[stat].max), _M.stats_def[stat].min)
	return self.stats[stat]
end
