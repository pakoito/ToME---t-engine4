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

--- A generic UI button
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.text = assert(t.text, "no button text")
	self.fct = assert(t.fct, "no button fct")
	self.force_w = t.width

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	local ls, ls_w, ls_h = self:getImage("ui/button-left-sel.png")
	local ms, ms_w, ms_h = self:getImage("ui/button-middle-sel.png")
	local rs, rs_w, rs_h = self:getImage("ui/button-right-sel.png")
	local l, l_w, l_h = self:getImage("ui/button-left.png")
	local m, m_w, m_h = self:getImage("ui/button-middle.png")
	local r, r_w, r_h = self:getImage("ui/button-right.png")

	-- Draw UI
	self.font:setStyle("bold")
	local w, h = self.font:size(self.text:removeColorCodes())
	if self.force_w then w = self.force_w end
	local fw, fh = w + ls_w + rs_w, ls_h
	local ss = core.display.newSurface(fw, fh)
	local s = core.display.newSurface(fw, fh)

	ss:merge(ls, 0, 0)
	for i = ls_w, fw - rs_w do ss:merge(ms, i, 0) end
	ss:merge(rs, fw - rs_w, 0)
	ss:drawColorStringBlended(self.font, self.text, ls_w, (fh - h) / 2, 255, 255, 255)

	s:merge(l, 0, 0)
	for i = l_w, fw - r_w do s:merge(m, i, 0) end
	s:merge(r, fw - r_w, 0)
	s:drawColorStringBlended(self.font, self.text, ls_w, (fh - h) / 2, 255, 255, 255)
	self.font:setStyle("normal")

	-- Add UI controls
	self.mouse:registerZone(0, 0, fw, fh, function(button, x, y, xrel, yrel, bx, by, event) if button == "left" and event == "button" then self.fct() end end)
	self.key:addBind("ACCEPT", function() self.fct() end)

	self.tex, self.tex_w, self.tex_h = s:glTexture()
	self.stex = ss:glTexture()
	self.rw, self.rh = fw, fh
	self.w, self.h = fw+10, fh+10
end

function _M:display(x, y)
	if self.focused then
		self.stex:toScreenFull(x+5, y+5, self.rw, self.rh, self.tex_w, self.tex_h)
	else
		self.tex:toScreenFull(x+5, y+5, self.rw, self.rh, self.tex_w, self.tex_h)
	end
end
