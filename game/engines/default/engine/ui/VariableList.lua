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
	self.fct = t.fct
	self.display_prop = t.display_prop or "name"

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self.sel = 1
	self.max = #self.list

	local vs7, vs7_w, vs7_h = self:getImage("ui/varsel-7-sel.png")
	local vs9, vs9_w, vs9_h = self:getImage("ui/varsel-9-sel.png")
	local vs3, vs3_w, vs3_h = self:getImage("ui/varsel-3-sel.png")
	local vs1, vs1_w, vs1_h = self:getImage("ui/varsel-1-sel.png")
	local vs2, vs2_w, vs2_h = self:getImage("ui/varsel-2-sel.png")
	local vs8, vs8_w, vs8_h = self:getImage("ui/varsel-8-sel.png")
	local vs4, vs4_w, vs4_h = self:getImage("ui/varsel-4-sel.png")
	local vs6, vs6_w, vs6_h = self:getImage("ui/varsel-6-sel.png")
	local vsc, vsc_w, vsc_h = self:getImage("ui/varsel-repeat-sel.png")

	local fw, fh = self.w, self.font_h
	self.fw, self.fh = fw, fh

	-- Draw the list items
	self.h = 0
	for i, item in ipairs(self.list) do
		local color = item.color or {255,255,255}
		local text = item[self.display_prop]:splitLines(fw - vs7_w - vs9_w, self.font)
		local fh = fh * #text + vs7_h / 3 * 2
		local ss = core.display.newSurface(fw, fh)
		local sus = core.display.newSurface(fw, fh)
		local s = core.display.newSurface(fw, fh)

		for i = 0, fw, vsc_w do for j = 0, fh, vsc_h do ss:merge(vsc, i, j) end end
		for i = 0, fw, vs8_w do ss:merge(vs8, i, 0) ss:merge(vs2, i, fh - vs2_h) end
		for j = 0, fh, vs4_h do ss:merge(vs4, 0, j) ss:merge(vs6, fw - vs6_w, j) end
		ss:merge(vs7, 0, 0)
		ss:merge(vs9, fw - vs9_w, 0)
		ss:merge(vs1, 0, fh - vs1_h)
		ss:merge(vs3, fw - vs3_w, fh - vs3_h)

		s:erase(0, 0, 0)

		local color_r, color_g, color_b = color[1], color[2], color[3]
		for z = 1, #text do
			s:drawColorStringBlended(self.font, text[z], vs7_w, vs7_h / 3 + self.font_h * (z-1), color_r, color_g, color_b)
			color_r, color_g, color_b = ss:drawColorStringBlended(self.font, text[z], vs7_w, vs7_h / 3 + self.font_h * (z-1), color_r, color_g, color_b)
		end

		item.fh = fh
		item._tex, item._tex_w, item._tex_h = s:glTexture()
		item._stex = ss:glTexture()

		self.mouse:registerZone(0, self.h, self.w, fh, function(button, x, y, xrel, yrel, bx, by, event)
			self.sel = i
			if button == "left" and event == "button" then self:onUse() end
		end)

		self.h = self.h + fh
	end

	-- Add UI controls
	self.key:addBinds{
		ACCEPT = function() self:onUse() end,
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, self.max) end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, self.max) end,
	}
end

function _M:onUse()
	local item = self.list[self.sel]
	if not item then return end
	if item.fct then item:fct()
	else self.fct(item, self.sel) end
end

function _M:display(x, y)
	for i = 1, self.max do
		local item = self.list[i]
		if not item then break end
		if self.sel == i then
			if self.focused then
				item._stex:toScreenFull(x, y, self.fw, item.fh, item._tex_w, item._tex_h)
			else
				item._tex:toScreenFull(x, y, self.fw, item.fh, item._tex_w, item._tex_h)
			end
		else
			item._tex:toScreenFull(x, y, self.fw, item.fh, item._tex_w, item._tex_h)
		end
		y = y + item.fh
	end
end
