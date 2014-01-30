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
	self.h = assert(t.height, "no list height")
	self.scrollbar = t.scrollbar
	self.focus_check = t.focus_check
	self.variable_height = t.variable_height

	self.dest_area = t.dest_area and t.dest_area or { h = self.h }
	self.max_h = 0
	self.scroll_inertia = 0

	if t.can_focus ~= nil then self.can_focus = t.can_focus end

	Base.init(self, t)

	self.sep = Separator.new{dir="vertical", size=self.w, ui=self.ui}
end

function _M:erase()
	self.surface:erase(0,0,0,0)
	self.surface:updateTexture(self.texture)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self.fw, self.fh = self.w, self.font_h

	-- Draw the scrollbar
	if self.scrollbar then
		self.scrollbar = Slider.new{size=self.h, max=1}
	end

	-- Add UI controls
	local on_mousewheel = function(button, x, y, xrel, yrel, bx, by, event)
		if button == "wheelup" and event == "button" then self.key:triggerVirtual("MOVE_UP")
		elseif button == "wheeldown" and event == "button" then self.key:triggerVirtual("MOVE_DOWN")
		end
		if button == "middle" and self.scrollbar then
			if not self.scroll_drag then
				self.scroll_drag = true
				self.scroll_drag_x_start = bx
				self.scroll_drag_y_start = by
			else
				self.scrollbar.pos = util.minBound(self.scrollbar.pos + by - self.scroll_drag_y_start, 0, self.scrollbar.max)
				self.scroll_drag_x_start = bx
				self.scroll_drag_y_start = by
			end
		else
			self.scroll_drag = false
		end
	end

	self.mouse:registerZone(0, 0, self.w, self.h, on_mousewheel)
	self.key:addBinds{
		MOVE_UP = function() if self.scrollbar then self.scroll_inertia = math.min(self.scroll_inertia, 0) - 10  end end,
		MOVE_DOWN = function() if self.scrollbar then self.scroll_inertia = math.max(self.scroll_inertia, 0) + 10  end end
	}

	self.key:addCommands{
		_HOME = function() if self.scrollbar then self.scrollbar.pos = 0 end end,
		_END = function() if self.scrollbar then self.scrollbar.pos = self.scrollbar.max end end,
		_PAGEUP = function() if self.scrollbar then self.scrollbar.pos = util.minBound(self.scrollbar.pos - self.h, 0, self.scrollbar.max) end end,
		_PAGEDOWN = function() if self.scrollbar then self.scrollbar.pos = util.minBound(self.scrollbar.pos + self.h, 0, self.scrollbar.max) end end,
	}
end

function _M:createItem(item, text)
	local gen = {}
	-- Draw the list items
	if self.scrollbar then
		gen = self.font:draw(text:toString(), self.fw - self.scrollbar.w , 255, 255, 255)
	else
		gen = self.font:draw(text:toString(), self.fw, 255, 255, 255)
	end

	self.max_h = 0
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
		if gen[i].is_separator then
			self.max_h = self.max_h + (self.fh - self.sep.h)
		else
			self.max_h = self.max_h + gen[i].h
		end
	end

	local max = #gen
	if self.variable_height then
		self.h = self.max_h
		if not self.dest_area.fixed then self.dest_area.h = self.max_h end
	end
	self.items[item] = { list = gen, max_h = self.max_h }
end

function _M:switchItem(item, create_if_needed, force)
	if self.cur_item == item and not force then return true end
	if (create_if_needed and not self.items[item]) or force then self:createItem(item, create_if_needed) end
	if not item or not self.items[item] then self.list = nil return false end
	local d = self.items[item]

	self.max_h = d.max_h
	if self.scrollbar then
		self.scrollbar.max = self.max_h - self.h
		self.scrollbar.pos = 0
	end
	if self.focus_check then if self.max_h > self.h then
		self.can_focus = true
	else
		self.can_focus = false
	end end
	self.list = d.list
	self.max_display = d.max_display
	self.cur_item = item
	return true
end

function _M:erase()
	self.list = {}
	self.items = {}
end

--@param x, y - x, y position of displaying
--@param nb_keyframes -
--@param ox, oy -
--@param offset_x, offset_y - offset values of UI element relative to its parent
--@param local_x, local_y - local starting values of UI element relative to its parent
function _M:display(x, y, nb_keyframes, ox, oy, offset_x, offset_y, local_x, local_y)
	if not self.list then return end
	offset_x = offset_x and offset_x or 0
	offset_y = offset_y and offset_y or (self.scrollbar and self.scrollbar.pos or 0)
	local_x = local_x and local_x or 0
	local_y = local_y and local_y or 0

	if self.scrollbar then
		self.scrollbar.pos = util.minBound(self.scrollbar.pos + self.scroll_inertia, 0, self.scrollbar.max)
		if self.scroll_inertia > 0 then self.scroll_inertia = math.max(self.scroll_inertia - 1, 0)
		elseif self.scroll_inertia < 0 then self.scroll_inertia = math.min(self.scroll_inertia + 1, 0)
		end
		if self.scrollbar.pos == 0 or self.scrollbar.pos == self.scrollbar.max then self.scroll_inertia = 0 end
	end

	local loffset_y = offset_y - local_y
	local current_y = 0
	local current_x = 0
	local total_h = 0
	local clip_y_start = 0
	local clip_y_end = 0
	for i = 1, #self.list do
		local item = self.list[i]
		clip_y_start = 0
		clip_y_end = 0

		local item_h = item.is_separator and (self.fh - self.sep.h) or item.h
		-- if item is within visible area bounds
		if total_h + item_h > loffset_y and total_h < loffset_y + self.dest_area.h then
			-- if it started before visible area then compute its top clip
			if total_h < loffset_y then
				clip_y_start = loffset_y - total_h
			end
			-- if it ended after visible area then compute its bottom clip
			if total_h + item_h > loffset_y + self.dest_area.h then
			   clip_y_end = total_h + item_h - (loffset_y + self.dest_area.h)
			end
			if item.background then
				core.display.drawQuad(x + current_x, y + current_y, item._tex_w, item_h - (clip_y_start + clip_y_end), item.background[1], item.background[2], item.background[3], item.background[4])
			end
			if item.is_separator then
				self.sep:display(x + current_x, y + current_y + (self.fh - self.sep.h) * 0.5 - clip_y_start, nb_keyframes, ox, oy, 0, total_h + (self.fh - self.sep.h) * 0.5, 0, loffset_y, self.dest_area)
			else
				local one_by_tex_h = 1 / item._tex_h
				if self.text_shadow then item._tex:toScreenPrecise(x + current_x + 1, y + current_y + 1, item.w, item_h - (clip_y_start + clip_y_end), 0, item.w / item._tex_w, clip_y_start * one_by_tex_h, (item_h - clip_y_end) * one_by_tex_h, 0, 0, 0, self.text_shadow) end
				item._tex:toScreenPrecise(x + current_x, y + current_y, item.w, item_h - (clip_y_start + clip_y_end), 0, item.w / item._tex_w, clip_y_start * one_by_tex_h, (item_h - clip_y_end) * one_by_tex_h )
			end
			-- add only visible part of item
			current_y = current_y + item_h - clip_y_start
		end
		-- add full size of item
		total_h = total_h + item_h
		-- if we are too deep then end this
		if total_h > loffset_y + self.dest_area.h then break end
	end
	if self.focused and self.scrollbar and self.h < self.max_h then
		self.scrollbar:display(x + self.w - self.scrollbar.w, y)
	end
end
