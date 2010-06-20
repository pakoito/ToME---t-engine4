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

--- Module that handles message history ina mouse wheel scrollable zone
module(..., package.seeall, class.make)

--- Creates the log zone
function _M:init(x, y, w, h, max, fontname, fontsize, color, bgcolor)
	self.color = color or {255,255,255}
	self.bgcolor = bgcolor or {0,0,0}
	self.display_x, self.display_y = math.floor(x), math.floor(y)
	self.w, self.h = math.floor(w), math.floor(h)
	self.font = core.display.newFont(fontname or "/data/font/Vera.ttf", fontsize or 12)
	self.font_h = self.font:lineSkip()
	self.surface = core.display.newSurface(w, h)
	self.log = {}
	getmetatable(self).__call = _M.call
	self.max = max or 4000
	self.scroll = 0
	self.changed = true
end

--- Resize the display area
function _M:resize(x, y, w, h)
	self.display_x, self.display_y = math.floor(x), math.floor(y)
	self.w, self.h = math.floor(w), math.floor(h)
	self.surface = core.display.newSurface(w, h)
	self.changed = true
end

--- Appends text to the log
-- This method is set as the call methamethod too, this means it is usable like this:<br/>
-- log = LogDisplay.new(...)<br/>
-- log("foo %s", s)
function _M:call(str, ...)
	local lines = str:format(...):splitLines(self.w - 4, self.font)
	for i = 1, #lines do
		print("[LOG]", lines[i])
		table.insert(self.log, 1, lines[i])
	end
	while #self.log > self.max do
		table.remove(self.log)
	end
	self.changed = true
end

--- Clear the log
function _M:empty()
	self.log = {}
	self.changed = true
end

function _M:display()
	-- If nothing changed, return the same surface as before
	if not self.changed then return self.surface end
	self.changed = false

	-- Erase and the display the map
	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])
	local i, dh = 1, 0
	while dh < self.h do
		if not self.log[self.scroll + i] then break end
		self.surface:drawColorStringBlended(self.font, self.log[self.scroll + i], 0, self.h - (i) * self.font_h, self.color[1], self.color[2], self.color[3])
		i = i + 1
		dh = dh + self.font_h
	end
	return self.surface
end

--- Scroll the zone
-- @param i number representing how many lines to scroll
function _M:scrollUp(i)
	self.scroll = self.scroll + i
	if self.scroll > #self.log - 1 then self.scroll = #self.log - 1 end
	if self.scroll < 0 then self.scroll = 0 end
	self.changed = true
end
