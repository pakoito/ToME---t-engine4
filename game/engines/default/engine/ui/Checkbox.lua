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

--- A generic UI textbox
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.title = assert(t.title, "no checkbox title")
	self.text = t.text or ""
	self.checked = t.default
	self.fct = assert(t.fct, "no checkbox fct")

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	local ls, ls_w, ls_h = self:getImage("ui/textbox-left-sel.png")
	local ms, ms_w, ms_h = self:getImage("ui/textbox-middle-sel.png")
	local rs, rs_w, rs_h = self:getImage("ui/textbox-right-sel.png")
	local l, l_w, l_h = self:getImage("ui/textbox-left.png")
	local m, m_w, m_h = self:getImage("ui/textbox-middle.png")
	local r, r_w, r_h = self:getImage("ui/textbox-right.png")
	local c, c_w, c_h = self:getImage("ui/textbox-cursor.png")
	local chk, chk_w, chk_h = self:getImage("ui/checkbox-ok.png")

	self.h = r_h

	-- Draw UI
	local title_w = self.font:size(self.title)
	self.w = title_w + chk_w
	local w, h = self.w, r_h
	local fw, fh = w - title_w - ls_w - rs_w, self.font_h
	self.fw, self.fh = fw, fh
	self.text_x = ls_w + title_w
	self.text_y = (h - fh) / 2
	self.max_display = math.floor(fw / self.font_mono_w)
	local ss = core.display.newSurface(w, h)
	local s = core.display.newSurface(w, h)

	ss:merge(ls, title_w, 0)
	for i = title_w + ls_w, w - rs_w do ss:merge(ms, i, 0) end
	ss:merge(rs, w - rs_w, 0)
	ss:drawColorStringBlended(self.font, self.title, 0, (h - fh) / 2, 255, 255, 255, true)

	s:merge(l, title_w, 0)
	for i = title_w + l_w, w - r_w do s:merge(m, i, 0) end
	s:merge(r, w - r_w, 0)
	s:drawColorStringBlended(self.font, self.title, 0, (h - fh) / 2, 255, 255, 255, true)

	self.chk_tex, self.chk_tex_w, self.chk_tex_h = chk:glTexture()
	self.chk_w, self.chk_h = chk_w, chk_h

	-- Add UI controls
	self.mouse:registerZone(title_w + ls_w, 0, fw, h, function(button, x, y, xrel, yrel, bx, by, event)
		if event == "button" then
			self:select()
		end
	end)
	self.key:addBind("ACCEPT", function() self.fct(self.checked) end)
	self.key:addCommands{
		_SPACE = function() self:select() end,
	}

	self.tex, self.tex_w, self.tex_h = s:glTexture()
	self.stex = ss:glTexture()
end

function _M:select()
	self.checked = not self.checked
end

function _M:display(x, y)
	if self.focused then
		self.stex:toScreenFull(x, y, self.w, self.h, self.tex_w, self.tex_h)
	else
		self.tex:toScreenFull(x, y, self.w, self.h, self.tex_w, self.tex_h)
	end
	if self.checked then
		self.chk_tex:toScreenFull(x + self.w - self.chk_w, y, self.chk_w, self.chk_h, self.chk_tex_w, self.chk_tex_h)
	end
end
