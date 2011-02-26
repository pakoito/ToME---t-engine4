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
local Base = require "engine.ui.Base"
local Focusable = require "engine.ui.Focusable"
local Slider = require "engine.ui.Slider"

--- A generic UI list
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.text = tostring(assert(t.text, "no textzone text"))
	if t.auto_width then t.width = 1 end
	self.w = assert(t.width, "no list width")
	if t.auto_height then t.height = 1 end
	self.h = assert(t.height, "no list height")
	self.scrollbar = t.scrollbar
	self.no_color_bleed = t.no_color_bleed
	self.auto_height = t.auto_height
	self.auto_width = t.auto_width
	self.color = t.color or {r=255, g=255, b=255}

	if self.auto_width then self.w = 10000 end

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	local text, max_w = self.text:toTString():splitLines(self.w, self.font)
	local max_lines = text:countLines()
	if self.auto_width then
		self.w = max_w
	end
	self.scroll = 1
	self.max = max_lines

	local fw, fh = self.w, self.font_h
	self.fw, self.fh = fw, fh

	if self.auto_height then self.h = self.fh * max_lines end

	self.max_display = math.floor(self.h / self.fh)
	self.can_focus = false
	if self.scrollbar and (self.max_display < self.max) then
		self.can_focus = true
	end

	-- Draw the list items
	self.list = tstring.makeLineTextures(text, self.fw, self.font, true, self.color.r, self.color.g, self.color.b)

	-- Draw the scrollbar
	if self.scrollbar then
		self.scrollbar = Slider.new{size=self.h - fh, max=self.max - self.max_display + 1}
	end

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		if button == "wheelup" and event == "button" then self.key:triggerVirtual("MOVE_UP")
		elseif button == "wheeldown" and event == "button" then self.key:triggerVirtual("MOVE_DOWN")
		end
	end)
	self.key:addBinds{
		MOVE_UP = function() self.scroll = util.bound(self.scroll - 1, 1, self.max - self.max_display + 1) end,
		MOVE_DOWN = function() self.scroll = util.bound(self.scroll + 1, 1, self.max - self.max_display + 1) end,
	}
end

function _M:spawn(t)
	local n = self:cloneFull()
	for k, e in pairs(t) do n[k] = e end
	n:generate()
	return n
end

function _M:display(x, y)
	local bx, by = x, y
	local max = math.min(self.scroll + self.max_display - 1, self.max)
	for i = self.scroll, max do
		local item = self.list[i]
		if not item then break end
		item._tex:toScreenFull(x, y, self.fw, self.fh, item._tex_w, item._tex_h)
		y = y + self.fh
	end

	if self.focused and self.scrollbar then
		self.scrollbar.pos = self.scroll
		self.scrollbar:display(bx + self.w - self.scrollbar.w, by)
	end
end
