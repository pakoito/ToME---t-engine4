-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
function _M:init(definition, datestring, start_year, start_day, start_hour)
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
	self.start_day = start_day or 1
	self.start_hour = start_hour or 8
end

function _M:getTimeDate(turn, dstr)
	local doy, year = self:getDayOfYear(turn)
	local hour, min = self:getTimeOfDay(turn)
	return (dstr or self.datestring):format(tostring(self:getDayOfMonth(doy)):ordinal(), self:getMonthName(doy), tostring(year):ordinal(), hour, min)
end

function _M:getDayOfYear(turn)
	local d, y
	turn = turn + self.start_hour * self.HOUR
	d = math.floor(turn / self.DAY) + (self.start_day - 1)
	y = math.floor(d / 365)
	d = math.floor(d % 365)
	return d, self.start_year + y
end

function _M:getTimeOfDay(turn)
	local hour, min
	turn = turn + self.start_hour * self.HOUR
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
