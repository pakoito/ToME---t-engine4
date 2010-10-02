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

--- A generic UI list
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.list = assert(t.list, "no list list")
	self.w = assert(t.width, "no list width")
	self.h = assert(t.height, "no list height")
	self.fct = t.fct
	self.display_prop = t.display_prop or "name"
	self.scrollbar = t.scrollbar

	Base.init(self, t)
end

function _M:generate()
	self.sel = 1
	self.scroll = 1
	self.max = #self.list

	local ls, ls_w, ls_h = self:getImage("ui/selection-left-sel.png")
	local ms, ms_w, ms_h = self:getImage("ui/selection-middle-sel.png")
	local rs, rs_w, rs_h = self:getImage("ui/selection-right-sel.png")
	local l, l_w, l_h = self:getImage("ui/selection-left.png")
	local m, m_w, m_h = self:getImage("ui/selection-middle.png")
	local r, r_w, r_h = self:getImage("ui/selection-right.png")

	local fw, fh = self.w, ls_h
	self.fw, self.fh = fw, fh

	self.max_display = math.floor(self.h / fh)

	-- Draw the scrollbar
	if self.scrollbar then
		local sb, sb_w, sb_h = self:getImage("ui/scrollbar.png")
		local ssb, ssb_w, ssb_h = self:getImage("ui/scrollbar-sel.png")

		self.scrollbar = { bar = {}, sel = {} }
		self.scrollbar.sel.w, self.scrollbar.sel.h, self.scrollbar.sel.tex, self.scrollbar.sel.texw, self.scrollbar.sel.texh = ssb_w, ssb_h, ssb:glTexture()
		local s = core.display.newSurface(sb_w, self.h - fh)
		for i = 0, self.h - fh do s:merge(sb, 0, i) end
		self.scrollbar.bar.w, self.scrollbar.bar.h, self.scrollbar.bar.tex, self.scrollbar.bar.texw, self.scrollbar.bar.texh = ssb_w, self.h - fh, s:glTexture()
	end

	-- Draw the list items
	for i, item in ipairs(self.list) do
		local text = item[self.display_prop]
		local ss = core.display.newSurface(fw, fh)
		local sus = core.display.newSurface(fw, fh)
		local s = core.display.newSurface(fw, fh)

		ss:merge(ls, 0, 0)
		for i = ls_w, fw - rs_w do ss:merge(ms, i, 0) end
		ss:merge(rs, fw - rs_w, 0)
		ss:drawColorStringBlended(self.font, text, ls_w, (fh - self.font_h) / 2, 255, 255, 255, nil, fw - ls_w - rs_w)

		s:erase(0, 0, 0)
		s:drawColorStringBlended(self.font, text, ls_w, (fh - self.font_h) / 2, 255, 255, 255, nil, fw - ls_w - rs_w)

		sus:merge(l, 0, 0)
		for i = l_w, fw - r_w do sus:merge(m, i, 0) end
		sus:merge(r, fw - r_w, 0)
		sus:drawColorStringBlended(self.font, text, ls_w, (fh - self.font_h) / 2, 255, 255, 255, nil, fw - ls_w - rs_w)

		item._tex, item._tex_w, item._tex_h = s:glTexture()
		item._stex = ss:glTexture()
		item._sustex = sus:glTexture()
	end

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		if button == "wheelup" and event == "button" then self.scroll = util.bound(self.scroll - 1, 1, self.max - self.max_display + 1)
		elseif button == "wheeldown" and event == "button" then self.scroll = util.bound(self.scroll + 1, 1, self.max - self.max_display + 1) end

		self.sel = util.bound(self.scroll + math.floor(by / self.fh), 1, self.max)
		if button == "left" and event == "button" then self:onUse() end
	end)
	self.key:addBinds{
		ACCEPT = function() self:onUse() end,
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, self.max) self.scroll = util.scroll(self.sel, self.scroll, self.max_display) end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, self.max) self.scroll = util.scroll(self.sel, self.scroll, self.max_display) end,
	}
	self.key:addCommands{
		_HOME = function()
			self.sel = 1
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
		end,
		_END = function()
			self.sel = self.max
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
		end,
		_PAGEUP = function()
			self.sel = util.bound(self.sel - self.max_display, 1, self.max)
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
		end,
		_PAGEDOWN = function()
			self.sel = util.bound(self.sel + self.max_display, 1, self.max)
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
		end,
	}
end

function _M:onUse()
	local item = self.list[self.sel]
	if not item then return end
	if item.fct then item:fct()
	else self.fct(item) end
end

function _M:display(x, y)
	local bx, by = x, y

	local max = math.min(self.scroll + self.max_display - 1, self.max)
	for i = self.scroll, max do
		local item = self.list[i]
		if self.sel == i then
			if self.focused then
				item._stex:toScreenFull(x, y, self.fw, self.fh, item._tex_w, item._tex_h)
			else
				item._sustex:toScreenFull(x, y, self.fw, self.fh, item._tex_w, item._tex_h)
			end
		else
			item._tex:toScreenFull(x, y, self.fw, self.fh, item._tex_w, item._tex_h)
		end
		y = y + self.fh
	end

	if self.focused and self.scrollbar then
		local pos = self.sel * (self.h - self.fh) / self.max

		self.scrollbar.bar.tex:toScreenFull(bx + self.w - self.scrollbar.bar.w, by + self.fh, self.scrollbar.bar.w, self.scrollbar.bar.h, self.scrollbar.bar.texw, self.scrollbar.bar.texh)
		self.scrollbar.sel.tex:toScreenFull(bx + self.w - self.scrollbar.sel.w, by + self.fh + pos, self.scrollbar.sel.w, self.scrollbar.sel.h, self.scrollbar.sel.texw, self.scrollbar.sel.texh)
	end
end
