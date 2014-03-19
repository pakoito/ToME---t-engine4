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
require "engine.Tiles"

local Dialog = require "engine.Dialog"

tiles = engine.Tiles.new(16, 16)

--- Handles control Cursor
-- This should work for anything that has a surface and x,y,w,h,font properties.
module(..., package.seeall, class.make)

function _M:startCursor()
	self.cursorPosition = 0
	self.maximumCursorPosition = 0
	self.focused = false
end

function _M:moveRight(x, add)
	if add and self.cursorPosition + x > self.maximumCursorPosition then self.maximumCursorPosition = self.cursorPosition + x end
	if self.cursorPosition + x <= self.maximumCursorPosition then
		self.cursorPosition = self.cursorPosition + x
	end
end

function _M:moveLeft(x)
	if self.cursorPosition - x >= 0 then
		self.cursorPosition = self.cursorPosition - x
	end
end

-- @param s surface to draw on
function _M:drawCursor(s, baseX, text)
	local sw, sh = self.font:size(text:sub(1, self.cursorPosition))
--	local t = os.time() % 2
	local t = 0
	if t < 1 and self.focused then
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "cursor.png"), sw + baseX, self.y + self.h - sh - 2)
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "cursor.png"), sw + baseX, self.y + self.h - sh - 10)
	end
end