-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

--- Interface to add leveling capabilities to actors
-- Defines the exp property, which is the current experience, level which is the current level and exp_worth which is a multiplier
-- to the monster level default exp
module(..., package.seeall, class.make)

_M.actors_max_level = false

_M.exp_chart = function(level)
	local exp = 10
	local mult = 10
	for i = 2, level do
		exp = exp + level * mult
		mult = mult + 1
	end
	return exp
end

function _M:init(t)
	self.exp = t.exp or 0
	self.exp_mod = t.exp_mod or 1
	self.exp_worth = t.exp_worth or 1
	self.level = self.level or 1
	self.start_level = self.start_level or 1

	if not t.level_range or self._actor_level_init then return end

	if t.level_range then
		self.level = 1
		self.start_level = t.level_range[1]
		self.max_level = t.level_range[2]
	else
		self.level = 1
		self.start_level = t.level or 1
	end
	self._actor_level_init = true
end

--- Resolves the correct level
-- called by self:resolve()
function _M:resolveLevel()
	self:forceLevelup(self.start_level)
end

--- Defines the experience chart used
-- Static!
-- @param chart either a table of format "[level] = exp_needed" or a function that takes one parameter, a level, and returns the experience needed to reach it.
function _M:defineExperienceChart(chart)
	assert(type(chart) == "table" or type(chart) == "function", "chart is neither table nor function")
	_M.exp_chart = chart
end

--- Defines the max level attainable
-- @param max the maximum level. Can be nil to not have a limit
-- Static!
function _M:defineMaxLevel(max)
	_M.actors_max_level = max
end

--- Get the exp needed for the given level
-- @param level the level to check exp for
-- @return the exp needed, or nil if this level is not achievable
function _M:getExpChart(level)
	if type(self.exp_chart) == "table" then
		return self.exp_chart[level] * self.exp_mod
	else
		return self.exp_chart(level) * self.exp_mod
	end
end

--- Gains some experience
-- If a levelup happens it calls self:levelup(), modules are encouraged to rewrite it to do whatever is needed.
function _M:gainExp(value)
	self.changed = true
	self.exp = math.max(0, self.exp + value)
	while self:getExpChart(self.level + 1) and self.exp >= self:getExpChart(self.level + 1) and (not self.actors_max_level or self.level < self.actors_max_level) do
		-- At max level, if any
		if self.actors_max_level and self.level >= self.actors_max_level then return end
		if self.max_level and self.level >= self.max_level then return end

		self.level = self.level + 1
		self.exp = self.exp - self:getExpChart(self.level)
		self:levelup()
	end
end

--- How much experience is this actor worth
-- @param target to whom is the exp rewarded
-- @return the experience rewarded
function _M:worthExp(target)
	return self.level * self.exp_worth * (target.exp_gain_mult or 1)
end

--- Method called when leveling up, module author rewrite it to do as you please
-- By default this will use infos left by resolvers.levelup() to increase properties
function _M:levelup()
	if not self._levelup_info then return end
	for what, info in pairs(self._levelup_info) do
		local base = self
		for i = 1, #info.kchain do
--			print(" * ", info.kchain[i])
			base = base[info.kchain[i]]
		end
		if not info.max or base[info.k] < info.max then
			local last = info.last or self.start_level
			if self.level - last >= info.every then
				base[info.k] = base[info.k] + util.getval(info.inc, self)
				info.last = self.level
			end
		end
--		print(" =>", base[info.k])
	end
end

--- Forces an actor to levelup to "lev"
function _M:forceLevelup(lev)
	while self.level < lev do
		-- At max level, if any
		if self.max_level and self.level >= self.max_level then break end

		self.level = self.level + 1
		self.exp = 0
		self:levelup()
	end
end
