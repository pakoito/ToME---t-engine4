require "engine.class"

--- Defines factions
module(..., package.seeall, class.make)

seconds_per_turn = 10

MINUTE = 60 / seconds_per_turn
HOUR = MINUTE * 60
DAY = HOUR * 24
YEAR = DAY * 365
DAY_START = HOUR * 6

--- Create a calendar
-- @param definition the file to load that returns a table containing calendar months
-- @param datestring a string to format the date when requested, in the format "%s %s %s %d %d", standing for, day, month, year, hour, minute
function _M:init(definition, datestring, start_year)
	local data = dofile(definition)
	self.calendar = {}
	local days = 0
	for _, e in ipairs(data) do
		if not e[3] then e[3] = 0 end
		table.insert(self.calendar, { days=days, name=e[2], length=e[1], offset=e[3] })
		days = days + e[1]
	end
	assert(days == 365, "Calendar incomplete, days ends at "..days.." instead of 365")

	self.datestring = datestring
	self.start_year = start_year
end

function _M:getTimeDate(turn)
	local doy, year = self:getDayOfYear(turn)
	local hour, min = self:getTimeOfDay(turn)
	return self.datestring:format(tostring(self:getDayOfMonth(doy)):ordinal(), self:getMonthName(doy), tostring(year):ordinal(), hour, min)
end

function _M:getDayOfYear(turn)
	local d, y
	d = math.floor(turn / self.DAY)
	y = math.floor(d / 365)
	d = math.floor(d % 365)
	return d, self.start_year + y
end

function _M:getTimeOfDay(turn)
	local hour, min
	min = math.floor((turn % self.DAY) / self.MINUTE)
	hour = math.floor(min / 60)
	min = math.floor(min % 60)
	return hour, min
end

function _M:getMonthNum(dayofyear)
	local i = #self.calendar

	-- Find the period name
	while ((i > 1) and (dayofyear < self.calendar[i].days)) do
		i = i - 1
	end

	return i
end

function _M:getMonthName(dayofyear)
	local month = self:getMonthNum(dayofyear)
	return self.calendar[month].name
end

function _M:getDayOfMonth(dayofyear)
	local month = self:getMonthNum(dayofyear)
	return dayofyear - self.calendar[month].days + 1 + self.calendar[month].offset
end

function _M:getMonthLength(dayofyear)
	local month = self:getMonthNum(dayofyear)
	return self.calendar[month].length
end
