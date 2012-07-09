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
local Base = require "engine.ui.Base"
local Focusable = require "engine.ui.Focusable"
local Slider = require "engine.ui.Slider"
local Separator = require "engine.ui.Separator"

--- A generic UI list
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.items = {}
	if t.weakstore then setmetatable(self.items, {__mode="k"}) end
	self.cur_item = 0
	self.w = assert(t.width, "no list width")
	if t.auto_height then t.height = 1 end
	self.h = assert(t.height, "no list height")
	self.scrollbar = t.scrollbar
	self.no_color_bleed = t.no_color_bleed
	self.variable_height = t.variable_height

	if self.scrollbar then
		self.can_focus = true
	end

	Base.init(self, t)

	self.sep = Separator.new{dir="vertical", size=self.w, ui=self.ui}
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self.fw, self.fh = self.w, self.font_h

	-- Draw the scrollbar
	if self.scrollbar then
		self.scrollbar = Slider.new{size=self.h - self.font_h, max=1}
	end

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		if button == "wheelup" and event == "button" then self.key:triggerVirtual("MOVE_UP")
		elseif button == "wheeldown" and event == "button" then self.key:triggerVirtual("MOVE_DOWN")
		end
	end)
	self.key:addBinds{
		MOVE_UP = function() if self.scroll then self.scroll = util.bound(self.scroll - 1, 1, self.max - self.max_display + 1) end end,
		MOVE_DOWN = function() if self.scroll then self.scroll = util.bound(self.scroll + 1, 1, self.max - self.max_display + 1) end end,
	}
end

function _M:createItem(item, text)
	local old_style = self.font:getStyle()
    
	local max_display = math.floor(self.h / self.fh)

		-- Draw the list items
		local gen = self.font:draw(text:toString(), self.fw, 255, 255, 255)

	for i = 1, #gen do
		if gen[i].line_extra then
			if gen[i].line_extra:sub(1, 7) == "linebg:" then
				local color = colors[gen[i].line_extra:sub(8)]
				if color then
					gen[i].background = colors.simple(color)
					gen[i].background[4] = 255
				else
					local c = gen[i].line_extra
					gen[i].background = {string.parseHex(c:sub(8, 9)), string.parseHex(c:sub(10, 11)), string.parseHex(c:sub(12, 13)), string.parseHex(c:sub(14, 15))}
				end
			end
		end
	end

	local max = #gen
	if self.variable_height then
		self.h = max * self.fh
		max_display = max
	end
	self.items[item] = {
		list = gen,
		scroll = 1,
		max = max,
		max_display = max_display,
	}
	self.font:setStyle(old_style)
end

function _M:switchItem(item, create_if_needed)
	self.cur_item = item
	if create_if_needed then if not self.items[item] then self:createItem(item, create_if_needed) end end
	if not item or not self.items[item] then self.list = nil return false end
	local d = self.items[item]

	self.scroll = d.scroll
	self.list = d.list
	self.max = d.max
	self.max_display = d.max_display
	self.cur_item = item
	return true
end

function _M:erase()
	self.list = {}
	self.items = {}
end

function _M:display(x, y)
	if not self.list then return end

	local bx, by = x, y
	local max = math.min(self.scroll + self.max_display - 1, self.max)
	for i = self.scroll, max do
		local item = self.list[i]
		if not item then break end

		if item.background then
			core.display.drawQuad(x, y, self.fw, self.fh, item.background[1], item.background[2], item.background[3], item.background[4])
		end

		if item.is_separator then
			self.sep:display(x, y + (self.fh - self.sep.h) / 2)
		else
			if self.text_shadow then item._tex:toScreenFull(x+1, y+1, item.w, item.h, item._tex_w, item._tex_h, 0, 0, 0, self.text_shadow) end
			item._tex:toScreenFull(x, y, item.w, item.h, item._tex_w, item._tex_h)
		end
		y = y + self.fh
	end

	if self.focused and self.scrollbar then
		self.scrollbar.pos = self.scroll
		self.scrollbar.pos = self.max - self.max_display + 1
		self.scrollbar:display(bx + self.w - self.scrollbar.w, by)
	end
end
