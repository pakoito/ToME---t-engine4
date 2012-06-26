-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	self.on_drag = t.on_drag
	self.on_drag_end = t.on_drag_end
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
		col.frame_special = self:makeFrame("ui/selector", col.width, self.fh)
		col.frame_sel = self:makeFrame("ui/selector-sel", col.width, self.fh)
		col.frame_usel = self:makeFrame("ui/selector", col.width, self.fh)
		col.frame_col = self:makeFrame("ui/heading", col.width, self.fh)
		col.frame_col_sel = self:makeFrame("ui/heading-sel", col.width, self.fh)
	end

	Base.init(self, t)
end

function _M:drawItem(item, nb_keyframes)
	nb_keyframes = (nb_keyframes or 0) / 2
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

			if item.color and type(item.color[1]) == "table" then
				color = item.color[j]
			end

			local s = col.surface

			s:erase(0, 0, 0, 0)
			local test_text = text:toString()
			local font_w, _ = self.font:size(test_text)

			if font_w > fw then
				item.displayx_offset = item.displayx_offset or {}
				item.displayx_offset[j] = item.displayx_offset[j] or 0
				item.dir = item.dir or {}
				item.dir[j] = item.dir[j] or 0

				if item.dir[j] == 0 then
					item.displayx_offset[j] = item.displayx_offset[j] - nb_keyframes
					if -item.displayx_offset[j] >= font_w - fw + 15 then
						item.dir[j] = 1
					end
				elseif item.dir[j] == 1 then
					item.displayx_offset[j] = item.displayx_offset[j] + nb_keyframes
					if item.displayx_offset[j] >= 0 then
						item.dir[j] = 0
					end
				end

				-- We use 1000 and do not cut lines to make sure it draws as much as possible
				text:drawOnSurface(s, 10000, nil, self.font, col.frame_sel.b4.w+item.displayx_offset[j], (fh - self.font_h) / 2, color[1], color[2], color[3])
				item.autoscroll = true
			else
				text:drawOnSurface(s, 10000, nil, self.font, col.frame_sel.b4.w, (fh - self.font_h) / 2, color[1], color[2], color[3])
			end

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
		if event == "motion" and button == "left" and self.on_drag then self.on_drag(self.list[self.sel], self.sel) end
		if button == "drag-end" and self.on_drag_end then self.on_drag_end(self.list[self.sel], self.sel) end
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
		[{"_UP","ctrl"}] = function() self.key:triggerVirtual("MOVE_UP") end,
		[{"_DOWN","ctrl"}] = function() self.key:triggerVirtual("MOVE_DOWN") end,
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

	local oldcol, oldrev = self.cur_col, self.sort_reverse
	self:selectColumn(oldcol or 1, (not oldcol) and true or false, self.sort_reverse)

	for i, item in ipairs(self.list) do self:drawItem(item) end
end

function _M:onSelect(force_refresh)
	local item = self.list[self.sel]
	if not item or (not force_refresh and self.previtem and self.previtem==item) then return end

	if rawget(self, "select") then self.select(item, self.sel) end
--	self.previtem = item
end

function _M:onUse(...)
	local item = self.list[self.sel]
	if not item then return end
	self:sound("button")
	if item.fct then item:fct(item, self.sel, ...)
	else self.fct(item, self.sel, ...) end
end

function _M:selectColumn(i, force, reverse)
	if not self.sortable and not force then return end
	local col = self.columns[i]
	if not col then return end

	if self.cur_col ~= i then
		self.cur_col = i
		self.sort_reverse = false
	else
		self.sort_reverse = not self.sort_reverse
	end
	if type(reverse) == "boolean" then self.sort_reverse = reverse end

	if self.sortable and not force then
		local fct = col.sort
		if type(fct) == "string" then fct = function(a, b) return a[col.sort] < b[col.sort] end end
		if self.sort_reverse and fct then local old=fct fct = function(a, b) return old(b, a) end end
		pcall(table.sort, self.list, fct)
	end
end

function _M:display(x, y, nb_keyframes, screen_x, screen_y)
	self.last_display_x = screen_x
	self.last_display_y = screen_y

	local bx, by = x, y
	if self.sel then
		local item = self.list[self.sel]
		if self.previtem and self.previtem~=item then
			self.previtem.displayx_offset = {}
			self:drawItem(self.previtem)
			self.previtem = nil
		end
		if item and item.autoscroll then
			self:drawItem(item, nb_keyframes)
			self.previtem = item
		end
	end

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

			if item.special_bg then
				local c = item.special_bg
				if type(c) == "function" then c = c(item) end
				if c then
					self:drawFrame(col.frame_special, x, y, c.r, c.g, c.b, c.a or 1)
				end
			end

			if col.direct_draw then
				col.direct_draw(item, x, y, col.fw, self.fh)
			elseif item._tex then
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
		self.scrollbar:display(bx + self.w - self.scrollbar.w, by + self.fh)
	end
end
