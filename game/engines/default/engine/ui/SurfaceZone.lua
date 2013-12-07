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
local Base = require "engine.ui.Base"
local Focusable = require "engine.ui.Focusable"

--- A generic UI list
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.w = assert(t.width, "no surface zone width")
	self.h = assert(t.height, "no surface zone height")
	self.alpha = t.alpha or 200

	self.s = core.display.newSurface(self.w, self.h)

	self.texture, self.texture_w, self.texture_h = self.s:glTexture()

	self.color = t.color or {r=255, g=255, b=255}

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self.s:updateTexture(self.texture)

	self.can_focus = false
end

function _M:update()
	self.s:updateTexture(self.texture)
end

function _M:display(x, y)
	if self.text_shadow then self.texture:toScreenFull(x+2, y+2, self.w, self.h, self.texture_w, self.texture_h, 0, 0, 0, self.text_shadow) end
	self.texture:toScreenFull(x, y, self.w, self.h, self.texture_w, self.texture_h)
end
