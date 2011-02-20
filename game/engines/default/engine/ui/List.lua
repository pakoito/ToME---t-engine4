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

local ls, ls_w, ls_h = _M:getImage("ui/selection-left-sel.png")
local ms, ms_w, ms_h = _M:getImage("ui/selection-middle-sel.png")
local rs, rs_w, rs_h = _M:getImage("ui/selection-right-sel.png")
local l, l_w, l_h = _M:getImage("ui/selection-left.png")
local m, m_w, m_h = _M:getImage("ui/selection-middle.png")
local r, r_w, r_h = _M:getImage("ui/selection-right.png")

function _M:init(t)
	self.list = assert(t.list, "no list list")
	self.w = assert(t.width, "no list width")
	self.h = t.height
	self.nb_items = t.nb_items
	assert(self.h or self.nb_items, "no list height/nb_items")
	self.fct = t.fct
	self.display_prop = t.display_prop or "name"
	self.scrollbar = t.scrollbar
	self.all_clicks = t.all_clicks

	self.fh = ls_h
	self.default = {}
	self.default.surface = core.display.newSurface(self.w, self.fh)
	self.default.s = core.display.newSurface(self.w, self.fh)
	self.default.ss = core.display.newSurface(self.w, self.fh)
	self.default.sus = core.display.newSurface(self.w, self.fh)

	self.default.ss:merge(ls, 0, 0)
	for i = ls_w, self.w - rs_w, ms_w do self.default.ss:merge(ms, i, 0) end
	self.default.ss:merge(rs, self.w - rs_w, 0)

	self.default.s:erase(0, 0, 0)

	self.default.sus:merge(l, 0, 0)
	for i = l_w, self.w - r_w, m_w do self.default.sus:merge(m, i, 0) end
	self.default.sus:merge(r, self.w - r_w, 0)

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self.sel = 1
	self.scroll = 1
	self.max = #self.list

	local fw, fh = self.w, ls_h
	self.fw, self.fh = fw, fh

	if not self.h then self.h = self.nb_items * fh end

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
		local color = item.color or {255,255,255}
		local text = item[self.display_prop]
		local src_ss = self.default.ss
		local src_sus = self.default.sus
		local src_s = self.default.s
		local ss = self.default.surface
		local sus = self.default.surface
		local s = self.default.surface

		ss:erase(0, 0, 0)
		ss:merge(src_ss, 0, 0)
		ss:drawColorStringBlended(self.font, text, ls_w, (fh - self.font_h) / 2, color[1], color[2], color[3], nil, fw - ls_w - rs_w)
		item._stex = ss:glTexture()

		s:merge(src_s, 0, 0)
		s:drawColorStringBlended(self.font, text, ls_w, (fh - self.font_h) / 2, color[1], color[2], color[3], nil, fw - ls_w - rs_w)
		item._tex, item._tex_w, item._tex_h = s:glTexture()

		sus:merge(src_sus, 0, 0)
		sus:drawColorStringBlended(self.font, text, ls_w, (fh - self.font_h) / 2, color[1], color[2], color[3], nil, fw - ls_w - rs_w)
		item._sustex = sus:glTexture()
	end

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		if button == "wheelup" and event == "button" then self.scroll = util.bound(self.scroll - 1, 1, self.max - self.max_display + 1)
		elseif button == "wheeldown" and event == "button" then self.scroll = util.bound(self.scroll + 1, 1, self.max - self.max_display + 1) end

		if self.sel then self.list[self.sel].focus_decay = self.focus_decay_max end
		self.sel = util.bound(self.scroll + math.floor(by / self.fh), 1, self.max)
		if (self.all_clicks or button == "left") and event == "button" then self:onUse(button) end
	end)
	self.key:addBinds{
		ACCEPT = function() self:onUse() end,
		MOVE_UP = function()
			if self.sel then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = util.boundWrap(self.sel - 1, 1, self.max) self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
		end,
		MOVE_DOWN = function()
			if self.sel then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = util.boundWrap(self.sel + 1, 1, self.max) self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
		end,
	}
	self.key:addCommands{
		_HOME = function()
			if self.sel then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = 1
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
		end,
		_END = function()
			if self.sel then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = self.max
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
		end,
		_PAGEUP = function()
			if self.sel then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = util.bound(self.sel - self.max_display, 1, self.max)
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
		end,
		_PAGEDOWN = function()
			if self.sel then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = util.bound(self.sel + self.max_display, 1, self.max)
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
		end,
	}
end

function _M:select(i)
	if self.sel then self.list[self.sel].focus_decay = self.focus_decay_max end
	self.sel = util.bound(i, 1, #self.list)
	self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
end

function _M:onUse(...)
	local item = self.list[self.sel]
	if not item then return end
	if item.fct then item:fct(item, self.sel, ...)
	else self.fct(item, self.sel, ...) end
end

function _M:display(x, y, nb_keyframes)
	local bx, by = x, y

	local max = math.min(self.scroll + self.max_display - 1, self.max)
	for i = self.scroll, max do
		local item = self.list[i]
		if not item then break end
		if self.sel == i then
			if self.focused then item._stex:toScreenFull(x, y, self.fw, self.fh, item._tex_w, item._tex_h)
			else item._sustex:toScreenFull(x, y, self.fw, self.fh, item._tex_w, item._tex_h) end
		else
			item._tex:toScreenFull(x, y, self.fw, self.fh, item._tex_w, item._tex_h)
			if item.focus_decay then
				if self.focused then item._stex:toScreenFull(x, y, self.fw, self.fh, item._tex_w, item._tex_h, 1, 1, 1, item.focus_decay / self.focus_decay_max_d)
				else item._sustex:toScreenFull(x, y, self.fw, self.fh, item._tex_w, item._tex_h, 1, 1, 1, item.focus_decay / self.focus_decay_max_d) end
				item.focus_decay = item.focus_decay - nb_keyframes
				if item.focus_decay <= 0 then item.focus_decay = nil end
			end
		end
		y = y + self.fh
	end

	if self.focused and self.scrollbar then
		local pos = self.sel * (self.h - self.fh) / self.max

		self.scrollbar.bar.tex:toScreenFull(bx + self.w - self.scrollbar.bar.w, by + self.fh, self.scrollbar.bar.w, self.scrollbar.bar.h, self.scrollbar.bar.texw, self.scrollbar.bar.texh)
		self.scrollbar.sel.tex:toScreenFull(bx + self.w - self.scrollbar.sel.w, by + self.fh + pos, self.scrollbar.sel.w, self.scrollbar.sel.h, self.scrollbar.sel.texw, self.scrollbar.sel.texh)
	end
end
