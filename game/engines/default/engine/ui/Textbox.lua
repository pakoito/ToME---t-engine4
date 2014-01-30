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

--- A generic UI textbox
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.title = assert(t.title, "no textbox title")
	self.text = t.text or ""
	self.size_title = t.size_title or t.title
	self.old_text = self.text
	self.on_mouse = t.on_mouse
	self.hide = t.hide
	self.on_change = t.on_change
	self.max_len = t.max_len or 999
	self.fct = assert(t.fct, "no textbox fct")
	self.chars = assert(t.chars, "no textbox chars")
	self.filter = t.filter or function(c) return c end

	self.tmp = {}
	for i = 1, #self.text do self.tmp[#self.tmp+1] = self.text:sub(i, i) end
	self.cursor = #self.tmp + 1
	self.scroll = 1

	Base.init(self, t)
end

function _M:on_focus(v)
	game:onTickEnd(function() self.key:unicodeInput(v) end)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	-- Draw UI
	local title_w = self.font:size(self.size_title)
	self.title_w = title_w
	local frame_w = self.chars * self.font_mono_w + 12
	self.w = title_w + frame_w
	self.h = self.font_h + 6

	self.texcursor = self:getUITexture("ui/textbox-cursor.png")
	self.frame = self:makeFrame("ui/textbox", frame_w, self.h)
	self.frame_sel = self:makeFrame("ui/textbox-sel", frame_w, self.h)

	local w, h = self.w, self.h
	local fw, fh = frame_w - 12, self.font_h
	self.fw, self.fh = fw, fh
	self.text_x = 6 + title_w
	self.text_y = (h - fh) / 2
	self.cursor_y = (h - self.texcursor.h) / 2
	self.max_display = math.floor(fw / self.font_mono_w)
	self.text_surf = core.display.newSurface(fw, fh)
	self.text_tex, self.text_tex_w, self.text_tex_h = self.text_surf:glTexture()
	self:updateText()

	if title_w > 0 then
		local s = core.display.newSurface(title_w, h)
		s:erase(0, 0, 0, 0)
		s:drawColorStringBlended(self.font, self.title, 0, (h - fh) / 2, 255, 255, 255, true)
		self.tex, self.tex_w, self.tex_h = s:glTexture()
	end

	-- Add UI controls
	self.mouse:registerZone(title_w + 6, 0, fw, h, function(button, x, y, xrel, yrel, bx, by, event)
		if event == "button" and button == "left" then
			self.cursor = util.bound(math.floor(bx / self.font_mono_w) + self.scroll, 1, #self.tmp+1)
			self:updateText()
		elseif event == "button" and self.on_mouse then
			self.on_mouse(button, x, y, xrel, yrel, bx, by, event)
		end
	end)
	self.key:addBind("ACCEPT", function() self.fct(self.text) end)
	self.key:addIgnore("_ESCAPE", true)
	self.key:addIgnore("_TAB", true)
	self.key:addIgnore("_UP", true)
	self.key:addIgnore("_DOWN", true)

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
				if self.filter(c) then
					table.insert(self.tmp, self.cursor, self.filter(c))
					self.cursor = self.cursor + 1
					self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
					self:updateText()
				end
			end
		end,
		[{"_v", "ctrl"}] = function(c)
			local s = core.key.getClipboard()
			if s then
				for i = 1, #s do
					if #self.tmp >= self.max_len then break end
					local c = string.sub(s, i, i)
					table.insert(self.tmp, self.cursor, self.filter(c))
					self.cursor = self.cursor + 1
					self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
				end
				self:updateText()
			end
		end,
	}
end

function _M:setText(text)
	self.text = text
	self.tmp = {}
	for i = 1, #self.text do self.tmp[#self.tmp+1] = self.text:sub(i, i) end
	self.cursor = #self.tmp + 1
	self.scroll = 1
	self:updateText()
end

function _M:updateText()
	if not self.tmp[1] then self.tmp = {} end
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
	if self.on_change and self.old_text ~= self.text then self.on_change(self.text) end
	self.old_text = self.text
end

function _M:display(x, y, nb_keyframes)
	if self.tex then
		if self.text_shadow then self.tex:toScreenFull(x+1, y+1, self.title_w, self.h, self.tex_w, self.tex_h, 0, 0, 0, self.text_shadow) end
		self.tex:toScreenFull(x, y, self.title_w, self.h, self.tex_w, self.tex_h)
	end
	if self.focused then
		self:drawFrame(self.frame_sel, x + self.title_w, y)
		self.texcursor.t:toScreenFull(x + self.text_x + (self.cursor-self.scroll) * self.font_mono_w, y + self.cursor_y, self.texcursor.w, self.texcursor.h, self.texcursor.tw, self.texcursor.th)
	else
		self:drawFrame(self.frame, x + self.title_w, y)
		if self.focus_decay then
			self:drawFrame(self.frame_sel, x + self.title_w, y, 1, 1, 1, self.focus_decay / self.focus_decay_max_d)
			self.focus_decay = self.focus_decay - nb_keyframes
			if self.focus_decay <= 0 then self.focus_decay = nil end
		end
	end
	if self.text_shadow then self.text_tex:toScreenFull(x+1 + self.text_x, y+1 + self.text_y, self.fw, self.fh, self.text_tex_w, self.text_tex_h, 0, 0, 0, self.text_shadow) end
	self.text_tex:toScreenFull(x + self.text_x, y + self.text_y, self.fw, self.fh, self.text_tex_w, self.text_tex_h)
end
