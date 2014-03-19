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

--- A generic UI button
module(..., package.seeall, class.inherit(Base))

function _M:init(t)
	self.dir = assert(t.dir, "no separator dir")
	self.size = assert(t.size, "no separator size")

	self.dest_area = {w = 1, h = 1}
	Base.init(self, t)
end

function _M:generate()
	if self.dir == "horizontal" then
		self.top = self:getUITexture("ui/border_vert_top.png")
		self.middle = self:getUITexture("ui/border_vert_middle.png")
		self.bottom = self:getUITexture("ui/border_vert_bottom.png")
		self.w, self.h = self.middle.w, self.size
		
	else
		self.left = self:getUITexture("ui/border_hor_left.png")
		self.middle = self:getUITexture("ui/border_hor_middle.png")
		self.right = self:getUITexture("ui/border_hor_right.png")
		self.w, self.h = self.size, self.middle.h
	end
	self.dest_area.w = self.w
	self.dest_area.h = self.h
end

function _M:display(x, y, total_w, nb_keyframes, ox, oy, total_h, loffset_x, loffset_y, dest_area)
	dest_area = dest_area or self.dest_area
	loffset_x = loffset_x and loffset_x or 0
	loffset_y = loffset_y and loffset_y or 0
	total_w = total_w and total_w or 0
	total_h = total_h and total_h or 0
	
	local clip_y_start = 0
	local clip_y_end = 0
	local clip_x_start = 0
	local clip_x_end = 0

	if total_h < loffset_y then clip_y_start = loffset_y - total_h end
	
	if self.dir == "horizontal" then
		if total_h + self.top.h > loffset_y and total_h < loffset_y + dest_area.h then
			if total_h + self.top.h > loffset_y + dest_area.h then clip_y_end = total_h + self.top.h - loffset_y - dest_area.h end
			local one_by_tex_h = 1 / self.top.th
			self.top.t:toScreenPrecise(x, y, self.top.w, self.top.h - clip_y_start - clip_y_end, 0, self.top.w / self.top.tw, clip_y_start * one_by_tex_h, (self.top.h - clip_y_end) * one_by_tex_h)
		end
		clip_y_end = 0
		
		if total_h + self.bottom.h > loffset_y and total_h < loffset_y + dest_area.h then
			if total_h + self.bottom.h > loffset_y + dest_area.h then clip_y_end = total_h + self.bottom.h - loffset_y - dest_area.h end
			local one_by_tex_h = 1 / self.bottom.th
			self.bottom.t:toScreenPrecise(x, y + self.h - self.bottom.h, self.bottom.w, self.bottom.h - clip_y_start - clip_y_end, 0, self.bottom.w / self.bottom.tw, clip_y_start * one_by_tex_h, (self.bottom.h - clip_y_end) * one_by_tex_h)
		end
		clip_y_end = 0
		
		if total_h + self.middle.h > loffset_y and total_h < loffset_y + dest_area.h then
			if total_h + self.middle.h > loffset_y + dest_area.h then clip_y_end = total_h + self.middle.h - loffset_y - dest_area.h end
			local one_by_tex_h = 1 / self.middle.th
			self.middle.t:toScreenPrecise(x, y + self.top.h, self.middle.w, self.h - self.top.h - self.bottom.h - clip_y_start - clip_y_end, 0, self.middle.w / self.middle.tw, clip_y_start * one_by_tex_h, (self.h - self.top.h - self.bottom.h - clip_y_end) * one_by_tex_h)
		end
	else
		if total_h + self.left.h > loffset_y and total_h < loffset_y + dest_area.h then
			if total_h + self.left.h > loffset_y + dest_area.h then clip_y_end = total_h + self.left.h - loffset_y - dest_area.h end
			local one_by_tex_h = 1 / self.left.th
			self.left.t:toScreenPrecise(x, y, self.left.w, self.left.h - clip_y_start - clip_y_end, 0, self.left.w / self.left.tw, clip_y_start * one_by_tex_h, (self.left.h - clip_y_end) * one_by_tex_h)
		end
		clip_y_end = 0
		
		if total_h + self.right.h > loffset_y and total_h < loffset_y + dest_area.h then
			if total_h + self.right.h > loffset_y + dest_area.h then clip_y_end = total_h + self.right.h - loffset_y - dest_area.h end
			local one_by_tex_h = 1 / self.right.th
			self.right.t:toScreenPrecise(x + self.w - self.right.w, y, self.right.w, self.right.h - clip_y_start - clip_y_end, 0, self.right.w / self.right.tw, clip_y_start * one_by_tex_h, (self.right.h - clip_y_end) * one_by_tex_h)
		end
		clip_y_end = 0
		
		if total_h + self.middle.h > loffset_y and total_h < loffset_y + dest_area.h then
			if total_h + self.middle.h > loffset_y + dest_area.h then clip_y_end = total_h + self.middle.h - loffset_y - dest_area.h end
			local one_by_tex_h = 1 / self.middle.th
			self.middle.t:toScreenPrecise(x + self.left.w, y, self.w - self.left.w - self.right.w, self.middle.h - clip_y_start - clip_y_end, 0, (self.w - self.left.w - self.right.w) / self.middle.tw, clip_y_start * one_by_tex_h, (self.middle.h - clip_y_end) * one_by_tex_h)
		end
	end
end
