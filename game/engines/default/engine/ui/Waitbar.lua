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

--- A generic waiter bar
module(..., package.seeall, class.inherit(Base))

function _M:init(t)
	self.size = assert(t.size, "no waiter size")
	self.text = assert(t.text, "no waiter text")
	self.fill = t.fill or 0
	self.maxfill = t.maxfill or 100

	Base.init(self, t)
end

function _M:updateFill(v, max, text)
	self.fill = v
	if max then self.maxfill = max end
	if text then
		self.text = text
		self.text_gen = self.font_bold:draw(self.text, self.text:toTString():maxWidth(self.font_bold), 255, 255, 255)[1]
	end
end

function _M:generate()
	self.t_left = self:getUITexture("ui/waiter/left_basic.png")
	self.t_right = self:getUITexture("ui/waiter/right_basic.png")
	self.t_middle = self:getUITexture("ui/waiter/middle.png")
	self.t_bar = self:getUITexture("ui/waiter/bar.png")

	self.w, self.h = self.size + self.t_left.w + self.t_right.w, self.t_left.h
end

function _M:display(x, y)
	self.t_middle.t:toScreenFull(x + self.t_left.w, y + (self.t_left.h - self.t_middle.h) / 2, self.size, self.t_middle.h, self.t_middle.tw, self.t_middle.th)
	self.t_left.t:toScreenFull(x, y, self.t_left.w, self.t_left.h, self.t_left.tw, self.t_left.th)
	self.t_right.t:toScreenFull(x + self.w - self.t_right.w, y, self.t_right.w, self.t_right.h, self.t_right.tw, self.t_right.th)
	if self.fill > 0 then
		self.t_bar.t:toScreenFull(x + self.t_left.w, y + (self.t_left.h - self.t_bar.h) / 2, self.size * self.fill / self.maxfill, self.t_bar.h, self.t_bar.tw, self.t_bar.th)
	end
	if self.text_gen then
		local item = self.text_gen
		item._tex:toScreenFull(2+x + (self.w - item.w) / 2, 2+y + (self.h - item.h) / 2, item.w, item.h, item._tex_w, item._tex_h, 0, 0, 0, 0.7)
		item._tex:toScreenFull(x + (self.w - item.w) / 2, y + (self.h - item.h) / 2, item.w, item.h, item._tex_w, item._tex_h, 1, 1, 1, 1)
	end
end
