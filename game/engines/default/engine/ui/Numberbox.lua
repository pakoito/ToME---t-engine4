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
	self.title = assert(t.title, "no numberbox title")
	self.number = t.number or 0
	self.min = t.min or 0
	self.on_change = t.on_change
	self.max = t.max or 9999999
	self.fct = assert(t.fct, "no numberbox fct")
	self.chars = assert(t.chars, "no numberbox chars")
	self.first = true

	self.tmp = {}
	local text = tostring(self.number)
	for i = 1, #text do self.tmp[#self.tmp+1] = text:sub(i, i) end
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
	local title_w = self.font:size(self.title)
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
		if event == "button" then
			self.cursor = util.bound(math.floor(bx / self.font_mono_w) + self.scroll, 1, #self.tmp+1)
			self:updateText()
		end
	end)
	self.key:addBind("ACCEPT", function() self.first = false self.fct(self.text) end)
	self.key:addIgnore("_ESCAPE", v)
	self.key:addIgnore("_TAB", true)
	self.key:addCommands{
		_UP = function() self.first = false self:updateText(1) end,
		_DOWN = function() self.first = false self:updateText(-1) end,
		_LEFT = function() self.first = false self.cursor = util.bound(self.cursor - 1, 1, #self.tmp+1) self.scroll = util.scroll(self.cursor, self.scroll, self.max_display) self:updateText() end,
		_RIGHT = function() self.first = false self.cursor = util.bound(self.cursor + 1, 1, #self.tmp+1) self.scroll = util.scroll(self.cursor, self.scroll, self.max_display) self:updateText() end,
		_DELETE = function()
			if self.first then self.first = false self.tmp = {} self:updateText() end
			if self.cursor <= #self.tmp then
				table.remove(self.tmp, self.cursor)
				self:updateText()
			end
		end,
		_BACKSPACE = function()
			if self.first then self.first = false self.tmp = {} self:updateText() end
			if self.cursor > 1 then
				table.remove(self.tmp, self.cursor - 1)
				self.cursor = self.cursor - 1
				self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
				self:updateText()
			end
		end,
		_HOME = function()
			self.first = false
			self.cursor = 1
			self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
			self:updateText()
		end,
		_END = function()
			self.first = false
			self.cursor = #self.tmp + 1
			self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
			self:updateText()
		end,
		__TEXTINPUT = function(c)
			if self.first then self.first = false self.tmp = {} self.cursor = 1 end
			if #self.tmp and (c == '-' or c == '0' or c == '1' or c == '2' or c == '3' or c == '4' or c == '5' or c == '6' or c == '7' or c == '8' or c == '9') then
				table.insert(self.tmp, self.cursor, c)
				self.cursor = self.cursor + 1
				self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
				self:updateText()
			end
		end,
	}
end

function _M:updateText(v)
	local old = self.number
	local text = ""
	if not v then
		if not self.tmp[1] then self.tmp = {} end
		self.number = tonumber(table.concat(self.tmp)) or 0
		self.number = util.bound(self.number, self.min, self.max)
		for i = self.scroll, self.scroll + self.max_display - 1 do
			if not self.tmp[i] then break end
			text = text .. self.tmp[i]
		end
	else
		self.number = self.number or 0
		self.number = util.bound(self.number + v, self.min, self.max)
		text = tostring(self.number)
		self.tmp = {}
		for i = 1, #text do self.tmp[#self.tmp+1] = text:sub(i, i) if not self.tmp[#self.tmp] then break end end
		self.cursor = #self.tmp + 1
	end

	self.text_surf:erase(0, 0, 0, 0)
	self.text_surf:drawStringBlended(self.font_mono, text, 0, 0, 255, 255, 255, true)
	self.text_surf:updateTexture(self.text_tex)
	if self.on_change and old ~= self.number then self.on_change(self.number) end
end

function _M:display(x, y, nb_keyframes)
	if self.tex then
		if self.text_shadow then self.tex:toScreenFull(x+1, y+1, self.title_w, self.h, self.tex_w, self.tex_h, 0, 0, 0, self.text_shadow) end
		self.tex:toScreenFull(x, y, self.title_w, self.h, self.tex_w, self.tex_h)
	end
	if self.focused then
		self:drawFrame(self.frame_sel, x + self.title_w, y)
		self.texcursor.t:toScreenFull(x + self.text_x + (self.cursor-self.scroll) * self.font_mono_w - (self.texcursor.w / 2), y + self.cursor_y, self.texcursor.w, self.texcursor.h, self.texcursor.tw, self.texcursor.th)
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
