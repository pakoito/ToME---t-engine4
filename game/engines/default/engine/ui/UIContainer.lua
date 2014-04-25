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

--- A generic UI list
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.w = assert(t.width, "no container width")
	self.h = assert(t.height, "no container height")
	self.dest_area = t.dest_area or { h = self.h }
	
	self:erase()
	
	self.scrollbar = Slider.new{size=self.h, max=0}
	self.uis_h = 0
	
	self.scroll_inertia = 0

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	-- Add UI controls
	local on_mousewheel = function(button, x, y, xrel, yrel, bx, by, event)
		if button == "wheelup" and event == "button" then self.key:triggerVirtual("MOVE_UP")
		elseif button == "wheeldown" and event == "button" then self.key:triggerVirtual("MOVE_DOWN")
		end
	end
	
	self.mouse:registerZone(0, 0, self.w, self.h, on_mousewheel)
	
	self.key:addBinds{
		MOVE_UP = function() if self.scrollbar.pos and self.uis_h > self.h then self.scroll_inertia = math.min(self.scroll_inertia, 0) - 5 end end,
		MOVE_DOWN = function() if self.scrollbar.pos and self.uis_h > self.h then self.scroll_inertia = math.max(self.scroll_inertia, 0) + 5 end end,
	}
end

function _M:erase()
	self.uis = {}
end

function _M:changeUI(uis)
	local max_h = 0
	self.uis = uis
	for i=1, #self.uis do
		max_h = max_h + self.uis[i].h
	end
	self.uis_h = max_h
	self.scrollbar.max = max_h - self.h
	if not self.dest_area.fixed then self.dest_area.h = max_h end
end

function _M:resize(w, h, dest_w, dest_h)
	self.w = w
	self.h = h
	self.dest_area.w = dest_w
	self.dest_area.h = dest_h
	self.scrollbar.max = self.uis_h - self.h
	self.scrollbar.pos = util.minBound(self.scrollbar.pos, 0, self.scrollbar.max)
	self.scrollbar.h = dest_h
end

function _M:display(x, y, nb_keyframes, screen_x, screen_y, offset_x, offset_y, local_x, local_y)
	local_x = local_x and local_x or 0
	local_y = local_y and local_y or 0
	
	if self.scrollbar then
		self.scrollbar.pos = util.minBound(self.scrollbar.pos + self.scroll_inertia, 0, self.scrollbar.max)
		if self.scroll_inertia > 0 then self.scroll_inertia = math.max(self.scroll_inertia - 1, 0)
		elseif self.scroll_inertia < 0 then self.scroll_inertia = math.min(self.scroll_inertia + 1, 0)
		end
		if self.scrollbar.pos == 0 or self.scrollbar.pos == self.scrollbar.max then self.scroll_inertia = 0 end
	end
	
	offset_x = offset_x and offset_x or 0
	offset_y = offset_y and offset_y or (self.scrollbar and self.scrollbar.pos or 0)
	
	local current_y = y
	local prev_loffset = 0
	local total_h = 0 
	local ui
	local first = true
	for i=1, #self.uis do
		ui = self.uis[i]
		ui.dest_area = ui.dest_area or {}
		ui.dest_area.h = self.dest_area.h
		if offset_y <= total_h + self.uis[i].h then 
			ui:display(x, current_y, nb_keyframes, x, current_y, offset_x, offset_y, local_x, local_y) 
			current_y = current_y + self.uis[i].h
			if total_h < offset_y then current_y = current_y + local_y - offset_y end
		end
		
		local_y = local_y + self.uis[i].h
		total_h = total_h + self.uis[i].h
		if total_h > offset_y + self.h then break end
	end
	
	if self.focused and self.uis_h > self.h then
		self.scrollbar:display(x + self.w - self.scrollbar.w, y)
	end
end
