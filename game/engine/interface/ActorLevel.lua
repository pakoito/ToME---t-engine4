require "engine.class"

--- Interface to add leveling capabilities to actors
-- Defines the exp property, which is the current experience, level which is the current level and exp_worth which is a multiplicator
-- to the monster level default exp
module(..., package.seeall, class.make)

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
	if t.level_range then
		self.level = t.level_range[1]
		self.max_level = t.level_range[2]
	else
		self.level = t.level or 1
	end
	self.exp = t.exp or 0
	self.exp_mod = t.exp_mod or 1
	self.exp_worth = t.exp_worth or 1
end

--- Defines the experience chart used
-- Static!
-- @param chart etiher a table of format "[level] = exp_needed" or a function that takes one parameter, a level, and returns the experience needed to reach it.
function _M:defineExperienceChart(chart)
	assert(type(chart) == "table" or type(chart) == "function", "chart is neither table nor function")
	self.exp_chart = chart
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
-- If a levelup happens it calls self:levelup(), modules are encourraged to rewrite it to do whatever is needed.
function _M:gainExp(value)
	self.exp = self.exp + value
	while self:getExpChart(self.level + 1) and self.exp >= self:getExpChart(self.level + 1) do
		-- At max level, if any
		if self.max_level and self.level >= self.max_level then break end

		self.level = self.level + 1
		self.exp = self.exp - self:getExpChart(self.level)
		self:levelup()
	end
end

--- How much experience is this actor worth
-- @return the experience rewarded
function _M:worthExp()
	return self.level * self.exp_worth
end

--- Method called when leveing up, module author rewrite it to do as you please
function _M:levelup()
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
