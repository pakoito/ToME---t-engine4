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
	self.level = t.level or 1
	self.exp = t.exp or 0
	self.exp_worth = t.exp_worth or 1
end

--- Defines the experience chart used
-- Static!
-- @param chart etiher a table of format "[level] = exp_needed" or a function that takes one parameter, a level, and returns the experience needed to reach it.
function _M:defineExperienceChart(chart)
	assert(type(chart) == "table" or type(chart) == "function", "chart is neither table nor function")
	self.exp_chart = chart
end

function _M:getExpChart(level)
	if type(self.exp_chart) == "table" then
		return self.exp_chart[level]
	else
		return self.exp_chart(level)
	end
end

--- Gains some experience
-- If a levelup happens it calls self:levelup(), modules are encourraged to rewrite it to do whatever is needed.
function _M:gainExp(value)
	print("gain exp",self.exp,"+",value)
	self.exp = self.exp + value
	while self:getExpChart(self.level + 1) and self.exp >= self:getExpChart(self.level + 1) do
		self.level = self.level + 1
		self.exp = self.exp - self:getExpChart(self.level)
		print("levelup", self.level, self.exp)
		self:levelup()
	end
end

--- How much experience is this actor worth
-- @return the experience rewarded
function _M:worthExp()
	return self.level * self.exp_worth
end

function _M:levelup()
end
