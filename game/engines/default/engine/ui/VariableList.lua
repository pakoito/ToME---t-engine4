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
	self.list = assert(t.list, "no list list")
	self.w = assert(t.width, "no list width")
	self.fct = t.fct
	self.select = t.select
	self.display_prop = t.display_prop or "name"

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self.sel = 1
	self.max = #self.list

	local fw, fh = self.w, self.font_h
	self.fw, self.fh = fw, fh

	self.frame = self:makeFrame(nil, fw, fh)
	self.frame_sel = self:makeFrame("ui/selector-sel", fw, fh)
	self.frame_usel = self:makeFrame("ui/selector", fw, fh)

	-- Draw the list items
	self.h = 0
	for i, item in ipairs(self.list) do
		local color = item.color or {255,255,255}
		local text = item[self.display_prop]:splitLines(fw - self.frame_sel.b4.w - self.frame_sel.b6.w, self.font)
		local fh = fh * #text + self.frame_sel.b8.w / 3 * 2
		local s = core.display.newSurface(fw, fh)

		s:erase(0, 0, 0, 0)
		local color_r, color_g, color_b = color[1], color[2], color[3]
		for z = 1, #text do
			color_r, color_g, color_b = s:drawColorStringBlended(self.font, text[z], self.frame_sel.b4.w, self.frame_sel.b8.w / 3 + self.font_h * (z-1), color_r, color_g, color_b, true)
		end

		item.fh = fh
		item._tex = {s:glTexture()}

		self.mouse:registerZone(0, self.h, self.w, fh, function(button, x, y, xrel, yrel, bx, by, event)
			if self.sel and self.list[self.sel] then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = i
			self:onSelect()
			if button == "left" and event == "button" then self:onUse() end
		end)

		self.h = self.h + fh
	end

	-- Add UI controls
	self.key:addBinds{
		ACCEPT = function() self:onUse() end,
		MOVE_UP = function()
			if self.sel and self.list[self.sel] then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = util.boundWrap(self.sel - 1, 1, self.max) self:onSelect()
		end,
		MOVE_DOWN = function()
			if self.sel and self.list[self.sel] then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = util.boundWrap(self.sel + 1, 1, self.max) self:onSelect()
		end,
	}
end

function _M:onUse()
	local item = self.list[self.sel]
	if not item then return end
	self:sound("button")
	if item.fct then item:fct()
	else self.fct(item, self.sel) end
end

function _M:onSelect()
	local item = self.list[self.sel]
	if not item then return end

	if rawget(self, "select") then self.select(item, self.sel) end
end

function _M:display(x, y, nb_keyframes)
	for i = 1, self.max do
		local item = self.list[i]
		if not item then break end

		self.frame.h = item.fh
		self.frame_sel.h = item.fh
		self.frame_usel.h = item.fh

		if self.sel == i then
			if self.focused then self:drawFrame(self.frame_sel, x, y)
			else self:drawFrame(self.frame_usel, x, y) end
		else
			self:drawFrame(self.frame, x, y)
			if item.focus_decay then
				if self.focused then self:drawFrame(self.frame_sel, x, y, 1, 1, 1, item.focus_decay / self.focus_decay_max_d)
				else self:drawFrame(self.frame_usel, x, y, 1, 1, 1, item.focus_decay / self.focus_decay_max_d) end
				item.focus_decay = item.focus_decay - nb_keyframes
				if item.focus_decay <= 0 then item.focus_decay = nil end
			end
		end
		if self.text_shadow then item._tex[1]:toScreenFull(x+1 + self.frame_sel.b4.w, y+1, self.fw, item.fh, item._tex[2], item._tex[3], 0, 0, 0, self.text_shadow) end
		item._tex[1]:toScreenFull(x + self.frame_sel.b4.w, y, self.fw, item.fh, item._tex[2], item._tex[3])
		y = y + item.fh
	end
end
