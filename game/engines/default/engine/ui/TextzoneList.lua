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
	self.items = {}
	self.cur_item = 0
	self.w = assert(t.width, "no list width")
	if t.auto_height then t.height = 1 end
	self.h = assert(t.height, "no list height")
	self.scrollbar = t.scrollbar
	self.no_color_bleed = t.no_color_bleed

	if self.scrollbar then
		self.can_focus = true
	end

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	local fw, fh = self.w, self.font_h
	self.fw, self.fh = fw, fh

	-- Draw the scrollbar
	if self.scrollbar then
		local sb, sb_w, sb_h = self:getImage("ui/scrollbar.png")
		local ssb, ssb_w, ssb_h = self:getImage("ui/scrollbar-sel.png")

		self.scrollbar = { bar = {}, sel = {} }
		self.scrollbar.sel.w, self.scrollbar.sel.h, self.scrollbar.sel.tex, self.scrollbar.sel.texw, self.scrollbar.sel.texh = ssb_w, ssb_h, ssb:glTexture()
		local s = core.display.newSurface(sb_w, self.h - fh)
		s:erase(200,0,0)
		for i = 0, self.h - fh do s:merge(sb, 0, i) end
		self.scrollbar.bar.w, self.scrollbar.bar.h, self.scrollbar.bar.tex, self.scrollbar.bar.texw, self.scrollbar.bar.texh = ssb_w, self.h - fh, s:glTexture()
	end

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		if button == "wheelup" and event == "button" then self.key:triggerVirtual("MOVE_UP")
		elseif button == "wheeldown" and event == "button" then self.key:triggerVirtual("MOVE_DOWN")
		end
	end)
	self.key:addBinds{
		MOVE_UP = function() self.scroll = util.bound(self.scroll - 1, 1, self.max - self.max_display + 1) end,
		MOVE_DOWN = function() self.scroll = util.bound(self.scroll + 1, 1, self.max - self.max_display + 1) end,
	}
end

function _M:createItem(item, text)
	-- Handle normal text
	if type(text) == "string" then
		local list = text:splitLines(self.w, self.font)
		local scroll = 1
		local max = #list
		local max_display = math.floor(self.h / self.fh)

		-- Draw the list items
		local gen = {}
		local r, g, b = 255, 255, 255
		local s = core.display.newSurface(self.fw, self.fh)
		for i, l in ipairs(list) do
			s:erase()
			r, g, b = s:drawColorStringBlended(self.font, l, 0, 0, r, g, b, true)
			if self.no_color_bleed then r, g, b = 255, 255, 255 end

			local dat = {}
			dat._tex, dat._tex_w, dat._tex_h = s:glTexture()
			gen[#gen+1] = dat
		end

		self.items[item] = {
			list = gen,
			scroll = scroll,
			max = max,
			max_display = max_display,
		}
	-- Handle "pre formated" text, as a table
	else
		-- Draw the list items
		local gen = tstring.makeLineTextures(text, self.fw, self.font)

		local scroll = 1
		local max = #gen
		local max_display = math.floor(self.h / self.fh)

		self.items[item] = {
			list = gen,
			scroll = scroll,
			max = max,
			max_display = max_display,
		}
	end
end

function _M:switchItem(item, create_if_needed)
	self.cur_item = item
	if create_if_needed then if not self.items[item] then self:createItem(item, create_if_needed) end end
	if not self.items[item] then self.list = nil return false end
	local d = self.items[item]

	self.scroll = d.scroll
	self.list = d.list
	self.max = d.max
	self.max_display = d.max_display
	self.cur_item = item
	return true
end

function _M:display(x, y)
	if not self.list then return end

	local bx, by = x, y
	local max = math.min(self.scroll + self.max_display - 1, self.max)
	for i = self.scroll, max do
		local item = self.list[i]
		if not item then break end
		item._tex:toScreenFull(x, y, self.fw, self.fh, item._tex_w, item._tex_h)
		y = y + self.fh
	end

	if self.focused and self.scrollbar then
		local pos = self.scroll * (self.h - self.fh) / (self.max - self.max_display + 1)

		self.scrollbar.bar.tex:toScreenFull(bx + self.w - self.scrollbar.bar.w, by + self.fh, self.scrollbar.bar.w, self.scrollbar.bar.h, self.scrollbar.bar.texw, self.scrollbar.bar.texh)
		self.scrollbar.sel.tex:toScreenFull(bx + self.w - self.scrollbar.sel.w, by + self.fh + pos, self.scrollbar.sel.w, self.scrollbar.sel.h, self.scrollbar.sel.texw, self.scrollbar.sel.texh)
	end
end
