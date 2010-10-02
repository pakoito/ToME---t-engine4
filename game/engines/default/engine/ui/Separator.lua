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

--- A generic UI button
module(..., package.seeall, class.inherit(Base))

function _M:init(t)
	self.dir = assert(t.dir, "no separator dir")
	self.size = assert(t.size, "no separator size")

	Base.init(self, t)
end

function _M:generate()
	if self.dir == "horizontal" then
		local b4, b4_w, b4_h = self:getImage("border_4.png")

		-- Draw UI
		self.w, self.h = b4_w, self.size
		local s = core.display.newSurface(self.w, self.h)

		for i = 0, self.size do s:merge(b4, 0, i) end

		self.tex, self.tex_w, self.tex_h = s:glTexture()
	else
		local b8, b8_w, b8_h = self:getImage("border_8.png")

		-- Draw UI
		self.w, self.h = self.size, b8_h
		local s = core.display.newSurface(self.w, self.h)

		for i = 0, self.size do s:merge(b8, i, 0) end

		self.tex, self.tex_w, self.tex_h = s:glTexture()
	end
end

function _M:display(x, y)
	self.tex:toScreenFull(x, y, self.w, self.h, self.tex_w, self.tex_h)
end
