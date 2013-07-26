-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
local Tiles = require "engine.Tiles"
local Base = require "engine.ui.Base"

--- A generic UI image
module(..., package.seeall, class.inherit(Base))

function _M:init(t)
	if t.tex then
		self.tex = t.tex
	else
		self.file = tostring(assert(t.file, "no image file"))
		self.image = Tiles:loadImage(self.file)
		local iw, ih = 0, 0
		if self.image then iw, ih = self.image:getSize() end
		self.iw, self.ih = iw, ih
		if t.auto_width then t.width = iw end
		if t.auto_height then t.height = ih end
	end
	self.w = assert(t.width, "no image width") * (t.zoom or 1)
	self.h = assert(t.height, "no image height") * (t.zoom or 1)
	self.back_color = t.back_color

	self.shadow = t.shadow

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	if self.image then self.item = self.tex or {self.image:glTexture()} end
end

function _M:display(x, y)
	if not self.item then return end

	if self.back_color then
		core.display.drawQuad(x, y, self.w, self.h, unpack(self.back_color))
	end

	if self.shadow then
		self.item[1]:toScreenFull(x + 5, y + 5, self.w, self.h, self.item[2], self.item[3], 0, 0, 0, 0.5)
	end

	self.item[1]:toScreenFull(x, y, self.w, self.h, self.item[2] * self.w / self.iw, self.item[3] * self.h / self.ih)
end
