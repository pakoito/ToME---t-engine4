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
	self.title = assert(t.title, "no textbox title")
	self.text = t.text or ""
	self.hide = t.hide
	self.max_len = t.max_len or 999
	self.fct = assert(t.fct, "no textbox fct")
	self.chars = assert(t.chars, "no textbox chars")

	self.tmp = {}
	for i = 1, #self.text do self.tmp[#self.tmp+1] = self.text:sub(i, i) end
	self.cursor = #self.tmp + 1
	self.scroll = 1

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

	self.h = r_h

	-- Draw UI
	local title_w = self.font:size(self.title)
	self.w = title_w + self.chars * self.font_mono_w + ls_w + rs_w
	local w, h = self.w, r_h
	local fw, fh = w - title_w - ls_w - rs_w, self.font_h
	self.fw, self.fh = fw, fh
	self.text_x = ls_w + title_w
	self.text_y = (h - fh) / 2
	self.max_display = math.floor(fw / self.font_mono_w)
	local ss = core.display.newSurface(w, h)
	local s = core.display.newSurface(w, h)
	self.text_surf = core.display.newSurface(fw, fh)
	self.text_tex, self.text_tex_w, self.text_tex_h = s:glTexture()
	self:updateText()

	ss:merge(ls, title_w, 0)
	for i = title_w + ls_w, w - rs_w do ss:merge(ms, i, 0) end
	ss:merge(rs, w - rs_w, 0)
	ss:drawColorStringBlended(self.font, self.title, 0, (h - fh) / 2, 255, 255, 255, true)

	s:merge(l, title_w, 0)
	for i = title_w + l_w, w - r_w do s:merge(m, i, 0) end
	s:merge(r, w - r_w, 0)
	s:drawColorStringBlended(self.font, self.title, 0, (h - fh) / 2, 255, 255, 255, true)

	local cursor = core.display.newSurface(c_w, fh)
	for i = 0, fh - 1 do cursor:merge(c, 0, i) end
	self.cursor_tex, self.cursor_tex_w, self.cursor_tex_h = cursor:glTexture()
	self.cursor_w, self.cursor_h = c_w, fh

	-- Add UI controls
	self.mouse:registerZone(title_w + ls_w, 0, fw, h, function(button, x, y, xrel, yrel, bx, by, event)
		if event == "button" then
			self.cursor = util.bound(math.floor(bx / self.font_mono_w) + self.scroll, 1, #self.tmp+1)
			self:updateText()
		end
	end)
	self.key:addBind("ACCEPT", function() self.fct(self.text) end)
	self.key:addCommands{
		_LEFT = function() self.cursor = util.bound(self.cursor - 1, 1, #self.tmp+1) self.scroll = util.scroll(self.cursor, self.scroll, self.max_display) self:updateText() end,
		_RIGHT = function() self.cursor = util.bound(self.cursor + 1, 1, #self.tmp+1) self.scroll = util.scroll(self.cursor, self.scroll, self.max_display) self:updateText() end,
		_DELETE = function()
			if self.cursor <= #self.tmp then
				table.remove(self.tmp, self.cursor)
				self:updateText()
			end
		end,
		_BACKSPACE = function()
			if self.cursor > 1 then
				table.remove(self.tmp, self.cursor - 1)
				self.cursor = self.cursor - 1
				self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
				self:updateText()
			end
		end,
		_HOME = function()
			self.cursor = 1
			self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
			self:updateText()
		end,
		_END = function()
			self.cursor = #self.tmp + 1
			self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
			self:updateText()
		end,
		__TEXTINPUT = function(c)
			if #self.tmp < self.max_len then
				table.insert(self.tmp, self.cursor, c)
				self.cursor = self.cursor + 1
				self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
				self:updateText()
			end
		end,
	}

	self.tex, self.tex_w, self.tex_h = s:glTexture()
	self.stex = ss:glTexture()
end

function _M:updateText()
	self.text = table.concat(self.tmp)
	local text = ""
	for i = self.scroll, self.scroll + self.max_display - 1 do
		if not self.tmp[i] then break end
		if not self.hide then text = text .. self.tmp[i]
		else text = text .. "*" end
	end

	self.text_surf:erase(0, 0, 0, 0)
	self.text_surf:drawStringBlended(self.font_mono, text, 0, 0, 255, 255, 255, true)
	self.text_surf:updateTexture(self.text_tex)
end

function _M:display(x, y)
	if self.focused then
		self.stex:toScreenFull(x, y, self.w, self.h, self.tex_w, self.tex_h)
		self.cursor_tex:toScreenFull(x + self.text_x + (self.cursor-self.scroll) * self.font_mono_w, y + self.text_y, self.cursor_w, self.cursor_h, self.cursor_tex_w, self.cursor_tex_h)
	else
		self.tex:toScreenFull(x, y, self.w, self.h, self.tex_w, self.tex_h)
	end
	self.text_tex:toScreenFull(x + self.text_x, y + self.text_y, self.fw, self.fh, self.text_tex_w, self.text_tex_h)
end
