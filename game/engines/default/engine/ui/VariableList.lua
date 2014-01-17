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
local Slider = require "engine.ui.Slider"

--- A generic UI list
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.list = assert(t.list, "no list list")
	self.w = assert(t.width, "no list width")
	self.max_h = t.max_height
	self.fct = t.fct
	self.select = t.select
	self.scrollbar = t.scrollbar
	self.min_items_shown = t.min_items_shown or 3
	self.display_prop = t.display_prop or "name"

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self.sel = 1
	self.scroll = 1
	self.max = #self.list

	local fw, fh = self.w, self.font_h
	self.fw, self.fh = fw, fh

	self.frame = self:makeFrame(nil, fw, fh)
	self.frame_sel = self:makeFrame("ui/selector-sel", fw, fh)
	self.frame_usel = self:makeFrame("ui/selector", fw, fh)

	-- Draw the list items
	local sh = 0
	local minh = 0
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

		item.start_h = sh
		item.fh = fh
		item._tex = {s:glTexture()}

		sh = sh + fh
		if i <= self.min_items_shown then minh = sh end
	end
	self.h = math.max(minh, math.min(self.max_h or 1000000, sh))
	if sh > self.h then self.scrollbar = true end

	self.scroll_inertia = 0
	self.scroll = 0
	if self.scrollbar then self.scrollbar = Slider.new{size=self.h, max=sh} end

	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		self.last_input_was_keyboard = false

		if event == "button" and button == "wheelup" then if self.scrollbar then self.scroll_inertia = math.min(self.scroll_inertia, 0) - 5 end
		elseif event == "button" and button == "wheeldown" then if self.scrollbar then self.scroll_inertia = math.max(self.scroll_inertia, 0) + 5 end
		end

		for i = 1, #self.list do
			local item = self.list[i]
			if by + self.scroll >= item.start_h and by + self.scroll < item.start_h + item.fh then
				if self.sel and self.list[self.sel] then self.list[self.sel].focus_decay = self.focus_decay_max end
				self.sel = i
				self:onSelect()
				if button == "left" and event == "button" then self:onUse() end
				break
			end
		end
	end)

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

	if self.scrollbar then
		local pos = 0
		for i = 1, #self.list do
			local itm = self.list[i]
			pos = pos + itm.fh
			-- we've reached selected row
			if self.sel == i then
				-- check if it was visible if not go scroll over there
				if pos - itm.fh < self.scrollbar.pos then self.scrollbar.pos = util.minBound(pos - itm.fh, 0, self.scrollbar.max)
				elseif pos > self.scrollbar.pos + self.h then self.scrollbar.pos = util.minBound(pos - self.h, 0, self.scrollbar.max)
				end
				break
			end
		end
	end

	if rawget(self, "select") then self.select(item, self.sel) end
end

function _M:display(x, y, nb_keyframes, screen_x, screen_y)
	local by = y
	core.display.glScissor(true, screen_x, screen_y, self.w, self.h)

	if self.scrollbar then
		local tmp_pos = self.scrollbar.pos
		self.scrollbar.pos = util.minBound(self.scrollbar.pos + self.scroll_inertia, 0, self.scrollbar.max)
		if self.scroll_inertia > 0 then self.scroll_inertia = math.max(self.scroll_inertia - 1, 0)
		elseif self.scroll_inertia < 0 then self.scroll_inertia = math.min(self.scroll_inertia + 1, 0)
		end
		if self.scrollbar.pos == 0 or self.scrollbar.pos == self.scrollbar.max then self.scroll_inertia = 0 end

		y = y + (self.scrollbar and -self.scrollbar.pos or 0)
		self.scroll = self.scrollbar.pos
	end

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

	core.display.glScissor(false)

	if self.focused and self.scrollbar then
		self.scrollbar:display(x + self.w - self.scrollbar.w, by)

		self.last_scroll = self.scrollbar.pos
	end
end
