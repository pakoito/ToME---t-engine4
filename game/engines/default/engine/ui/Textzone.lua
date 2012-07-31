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

--- A generic UI list
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.text = tostring(assert(t.text, "no textzone text"))
	
	if t.auto_height then t.height = 1 end
	if t.auto_width then t.width = 1 end
	
	self.w = assert(t.width, "no list width")
	self.h = assert(t.height, "no list height")
	self.scrollbar = t.scrollbar
	self.auto_height = t.auto_height
	self.auto_width = t.auto_width
	
	self.dest_area = t.dest_area and t.dest_area or { h = self.h }
	
	self.color = t.color or {r=255, g=255, b=255}
	self.can_focus = false
	self.scroll_inertia = 0

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()
	
	if self.scrollbar then 
		self.can_focus = true
		self.scrollbar = Slider.new{size=self.h, max=1} 
	end

	local gen, max_lines, max_w = self.font:draw(self.text, self.auto_width and self.text:toTString():maxWidth(self.font) or (self.scrollbar and self.w - self.scrollbar.w or self.w), self.color.r, self.color.g, self.color.b)
	if self.auto_width then self.w = max_w end
	
	self.max = max_lines

	if self.auto_height then 
		self.h = self.font_h * max_lines 
		self.dest_area.h = self.h 
	end

	self.max_display = max_lines * self.font_h
	self.list = gen

	if self.scrollbar then self.scrollbar.max=self.max_display - self.h end

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
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
	end)
	
	self.key:addBinds{
		MOVE_UP = function() if self.scrollbar then self.scroll_inertia = math.min(self.scroll_inertia, 0) - 10  end end,
		MOVE_DOWN = function() if self.scrollbar then self.scroll_inertia = math.max(self.scroll_inertia, 0) + 10  end end,
	}
	
	self.key:addCommands{
		_HOME = function() if self.scrollbar then self.scrollbar.pos = 0 end end,
		_END = function() if self.scrollbar then self.scrollbar.pos = self.scrollbar.max end end,
		_PAGEUP = function() if self.scrollbar then self.scrollbar.pos = util.minBound(self.scrollbar.pos - self.h, 0, self.scrollbar.max) end end,
		_PAGEDOWN = function() if self.scrollbar then self.scrollbar.pos = util.minBound(self.scrollbar.pos + self.h, 0, self.scrollbar.max) end end,
	}
end

function _M:display(x, y, nb_keyframes, screen_x, screen_y, offset_x, offset_y, local_x, local_y)
	if not self.list then return end
	offset_x = offset_x and offset_x or 0
	offset_y = (offset_y and offset_y) or (self.scrollbar and self.scrollbar.pos or 0)
	local_x = local_x and local_x or 0
	local_y = local_y and local_y or 0
	
	local loffset_y = offset_y - local_y
	local current_y = 0
	local current_x = 0
	local total_h = 0
	local clip_y_start = 0
	local clip_y_end = 0
	
	if self.scrollbar then
		self.scrollbar.pos = util.minBound(self.scrollbar.pos + self.scroll_inertia, 0, self.scrollbar.max)
		if self.scroll_inertia > 0 then self.scroll_inertia = math.max(self.scroll_inertia - 1, 0)
		elseif self.scroll_inertia < 0 then self.scroll_inertia = math.min(self.scroll_inertia + 1, 0)
		end
		if self.scrollbar.pos == 0 or self.scrollbar.pos == self.scrollbar.max then self.scroll_inertia = 0 end
	end
	
	local scroll_w = 0
	if self.focused and self.scrollbar and self.h < self.max_display then
		scroll_w = self.w
	end
	
	for i = 1, #self.list do
		local item = self.list[i]
		clip_y_start = 0
		clip_y_end = 0
		
		-- if item is within visible area bounds
		if total_h + item.h > loffset_y and total_h < loffset_y + self.dest_area.h then
			-- if it started before visible area then compute its top clip
			if total_h < loffset_y then 
				clip_y_start = loffset_y - total_h 
			end
			-- if it ended after visible area then compute its bottom clip
			if total_h + item.h > loffset_y + self.dest_area.h then 
			   clip_y_end = total_h + item.h - (loffset_y + self.dest_area.h)
			end
			if item.background then
				core.display.drawQuad(x + current_x, y + current_y, item._tex_w, item.h - (clip_y_start + clip_y_end), item.background[1], item.background[2], item.background[3], item.background[4])
			end

			local one_by_tex_h = 1 / item._tex_h
			if self.text_shadow then item._tex:toScreenPrecise(x + current_x + 1, y + current_y + 1, item.w, item.h - (clip_y_start + clip_y_end), 0, item.w / item._tex_w, clip_y_start * one_by_tex_h, (item.h - clip_y_end) * one_by_tex_h, 0, 0, 0, self.text_shadow) end
			item._tex:toScreenPrecise(x + current_x, y + current_y, item.w, item.h - (clip_y_start + clip_y_end), 0, item.w / item._tex_w, clip_y_start * one_by_tex_h, (item.h - clip_y_end) * one_by_tex_h )
			-- add only visible part of item
			current_y = current_y + item.h - clip_y_start
		end
		-- add full size of item
		total_h = total_h + item.h
		-- if we are too deep then end this
		if total_h > loffset_y + self.dest_area.h then break end
	end
	if self.focused and self.scrollbar and self.h < self.max_display then
		self.scrollbar:display(x + self.w - self.scrollbar.w, y)
	end
end
