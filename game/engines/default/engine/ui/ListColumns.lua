-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

--- A generic UI multi columns list
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.list = assert(t.list, "no list list")
	self.columns = assert(t.columns, "no list columns")
	self.w = assert(t.width, "no list width")
	self.h = t.height
	self.nb_items = t.nb_items
	assert(self.h or self.nb_items, "no list height/nb_items")
	self.sortable = t.sortable
	self.scrollbar = t.scrollbar
	self.fct = t.fct
	self.select = t.select
	self.all_clicks = t.all_clicks
	self.hide_columns = t.hide_columns

	self.fh = t.item_height or ls_h

	self.fh = t.item_height or (self.font_h + 6)

	local w = self.w
	if self.scrollbar then w = w - 10 end
	for j, col in ipairs(self.columns) do
		if type(col.width) == "table" then
			if col.width[2] == "fixed" then
				w = w - col.width[1]
			end
		end
	end
	for j, col in ipairs(self.columns) do
		if type(col.width) == "table" then
			if col.width[2] == "fixed" then
				col.width = col.width[1]
			end
		else
			col.width = w * col.width / 100
		end

		col.surface = core.display.newSurface(col.width, self.fh)
		col.frame = self:makeFrame(nil, col.width, self.fh)
		col.frame_sel = self:makeFrame("ui/selector-sel", col.width, self.fh)
		col.frame_usel = self:makeFrame("ui/selector", col.width, self.fh)
		col.frame_col = self:makeFrame("ui/heading", col.width, self.fh)
		col.frame_col_sel = self:makeFrame("ui/heading-sel", col.width, self.fh)
	end

	Base.init(self, t)
end

function _M:drawItem(item)
	for j, col in ipairs(self.columns) do
		if not col.direct_draw then
			local fw, fh = col.fw, self.fh

			local text
			if type(col.display_prop) == "function" then
				text = col.display_prop(item)
			else
				text = item[col.display_prop or col.sort]
			end
			if type(text) ~= "table" or not text.is_tstring then
				text = util.getval(text, item)
				if type(text) ~= "table" then text = tstring.from(tostring(text)) end
			end
			local color = item.color or {255,255,255}
			local s = col.surface

			s:erase(0, 0, 0, 0)
			-- We use 1000 and do not cut lines to make sure it draws as much as possible
			text:drawOnSurface(s, 10000, nil, self.font, col.frame_sel.b4.w, (fh - self.font_h) / 2, color[1], color[2], color[3])
			item._tex = item._tex or {}
			item._tex[j] = {s:glTexture()}
		end
	end
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self.sel = 1
	self.scroll = 1
	self.max = #self.list
	self:selectColumn(1, true)

	local fh = self.fh

	if not self.h then self.h = self.nb_items * fh end

	self.max_display = math.floor(self.h / fh) - 1

	-- Draw the scrollbar
	if self.scrollbar then
		self.scrollbar = Slider.new{size=self.h - fh, max=self.max}
	end

	-- Draw the list columns
	local colx = 0
	for j, col in ipairs(self.columns) do
		local fw = col.width
		col.fw = fw
		local text = col.name
		local s = col.surface

		self.font:setStyle("bold")
		s:erase(0, 0, 0, 0)
		s:drawColorStringBlended(self.font, text, col.frame_sel.b4.w, (fh - self.font_h) / 2, 255, 255, 255, true, fw - col.frame_sel.b4.w - col.frame_sel.b6.w)
		self.font:setStyle("normal")

		col._tex, col._tex_w, col._tex_h = s:glTexture()

		self.mouse:registerZone(colx, 0, col.width, self.fh, function(button, x, y, xrel, yrel, bx, by, event)
			if button == "left" and event == "button" then self:selectColumn(j) end
		end)
		colx = colx + col.width
	end

	-- Draw the list items
	for i, item in ipairs(self.list) do self:drawItem(item) end

	-- Add UI controls
	self.mouse:registerZone(0, self.fh, self.w, self.h - (self.hide_columns and 0 or self.fh), function(button, x, y, xrel, yrel, bx, by, event)
		if button == "wheelup" and event == "button" then self.scroll = util.bound(self.scroll - 1, 1, self.max - self.max_display + 1)
		elseif button == "wheeldown" and event == "button" then self.scroll = util.bound(self.scroll + 1, 1, self.max - self.max_display + 1) end

		if self.sel and self.list[self.sel] then self.list[self.sel].focus_decay = self.focus_decay_max end
		self.sel = util.bound(self.scroll + math.floor(by / self.fh), 1, self.max)
		self:onSelect()
		if (self.all_clicks or button == "left") and event == "button" then self:onUse(button, event) end
	end)
	self.key:addBinds{
		ACCEPT = function() self:onUse("left", "key") end,
		MOVE_UP = function()
			if self.sel and self.list[self.sel] then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = util.boundWrap(self.sel - 1, 1, self.max) self.scroll = util.scroll(self.sel, self.scroll, self.max_display) self:onSelect()
		end,
		MOVE_DOWN = function()
			if self.sel and self.list[self.sel] then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = util.boundWrap(self.sel + 1, 1, self.max) self.scroll = util.scroll(self.sel, self.scroll, self.max_display) self:onSelect()
		end,
	}
	self.key:addCommands{
		_HOME = function()
			if self.sel and self.list[self.sel] then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = 1
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
			self:onSelect()
		end,
		_END = function()
			if self.sel and self.list[self.sel] then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = self.max
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
			self:onSelect()
		end,
		_PAGEUP = function()
			if self.sel and self.list[self.sel] then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = util.bound(self.sel - self.max_display, 1, self.max)
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
			self:onSelect()
		end,
		_PAGEDOWN = function()
			if self.sel and self.list[self.sel] then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = util.bound(self.sel + self.max_display, 1, self.max)
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
			self:onSelect()
		end,
	}

	self:onSelect()
end

function _M:setList(list)
	self.list = list
	self.max = #self.list
	self.sel = util.bound(self.sel, 1, self.max)
	self.scroll = util.bound(self.scroll, 1, self.max)
	self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
	self:selectColumn(1, true)

	for i, item in ipairs(self.list) do self:drawItem(item) end
end

function _M:onSelect()
	local item = self.list[self.sel]
	if not item then return end

	if rawget(self, "select") then self.select(item, self.sel) end
end

function _M:onUse(...)
	local item = self.list[self.sel]
	if not item then return end
	if item.fct then item:fct(item, self.sel, ...)
	else self.fct(item, self.sel, ...) end
end

function _M:selectColumn(i, force)
	if not self.sortable and not force then return end
	local col = self.columns[i]
	if not col then return end

	if self.cur_col ~= i then
		self.cur_col = i
		self.sort_reverse = false
	else
		self.sort_reverse = not self.sort_reverse
	end

	if self.sortable and not force then
		local fct = col.sort
		if type(fct) == "string" then fct = function(a, b) return a[col.sort] < b[col.sort] end end
		if self.sort_reverse then local old=fct fct = function(a, b) return old(b, a) end end
		table.sort(self.list, fct)
	end
end

function _M:display(x, y, nb_keyframes, screen_x, screen_y)
	local bx, by = x, y
	for j = 1, #self.columns do
		local col = self.columns[j]
		local y = y
		if not self.hide_columns then
			if self.cur_col == j then self:drawFrame(col.frame_col, x, y)
			else self:drawFrame(col.frame_col_sel, x, y) end
			col._tex:toScreenFull(x, y, col.fw, self.fh, col._tex_w, col._tex_h)
			y = y + self.fh
		end

		local max = math.min(self.scroll + self.max_display - 1, self.max)
		for i = self.scroll, max do
			local item = self.list[i]
			if not item then break end
			if self.sel == i then
				if self.focused then self:drawFrame(col.frame_sel, x, y)
				else self:drawFrame(col.frame_usel, x, y) end
			else
				self:drawFrame(col.frame, x, y)
				if item.focus_decay then
					if self.focused then self:drawFrame(col.frame_sel, x, y, 1, 1, 1, item.focus_decay / self.focus_decay_max_d)
					else self:drawFrame(col.frame_usel, x, y, 1, 1, 1, item.focus_decay / self.focus_decay_max_d) end
					item.focus_decay = item.focus_decay - nb_keyframes
					if item.focus_decay <= 0 then item.focus_decay = nil end
				end
			end
			if col.direct_draw then
				col.direct_draw(item, x, y, col.fw, self.fh)
			else
				if self.text_shadow then item._tex[j][1]:toScreenFull(x+1, y+1, col.fw, self.fh, item._tex[j][2], item._tex[j][3], 0, 0, 0, self.text_shadow) end
				item._tex[j][1]:toScreenFull(x, y, col.fw, self.fh, item._tex[j][2], item._tex[j][3])
			end
			item.last_display_x = screen_x + (x - bx)
			item.last_display_y = screen_y + (y - by)
			y = y + self.fh
		end

		x = x + col.width
	end

	if self.focused and self.scrollbar then
		self.scrollbar.pos = self.sel
		self.scrollbar:display(bx + self.w - self.scrollbar.w, by)
	end
end
