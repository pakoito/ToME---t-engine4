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
	self.list = assert(t.list, "no list entires")
	self.columns = assert(t.columns, "no list columns")
	self.w = assert(t.width, "no list width")
	assert(t.height or t.nb_items, "no list height/nb_items")
	self.nb_rows = t.nb_items
	self.font = t.font or self.font
	self.row_height = t.item_height or (self.font_h + 6)
	self.h = t.height or self.row_height * ( (self.nb_rows or 0) + (self.hide_columns and 1 or 0) )
	self.sortable = t.sortable
	self.scrollbar = t.scrollbar
	self.fct = t.fct
	self.on_select = t.select
	self.on_drag = t.on_drag
	self.on_drag_end = t.on_drag_end
	self.all_clicks = t.all_clicks
	self.floating_headers = t.floating_headers or true
	self.hide_columns = t.hide_columns or false
	self.dest_area = t.dest_area and t.dest_area or { h = self.h }
	self.text_shadow = t.text_shadow or self.text_shadow
	self.click_select = t.click_select or false
	self.only_display = t.only_display or false

	self.max_h = 0
	self.max_h_columns = 0
	self.prevrow = 0
	self.prevclick = 0
	self.last_input_was_keyboard = false
	self.scroll_inertia = 0

	self.mouse_pos = { x = 0, y = 0 }

	if self.scrollbar then self.scrollbar = Slider.new{size=self.h, max=1} end

	self:setColumns(t.columns)

	Base.init(self, t)
end

function _M:generate()
	-- Create the scrollbar
	if self.scrollbar then self.scrollbar.h = self.h - (self.hide_columns and 0 or self.max_h_columns) end

	self.sel = 1
	self:selectColumn(1, true)

	-- Init rows
	for i=1, #self.list do
		local row = self.list[i]
		self:generateRow(row)
		self.max_h = self.max_h + row.h
	end
	if self.scrollbar then
		self.scrollbar.max = self.max_h - self.h
		self.scrollbar.pos = 0
	end

	self:setupInput()
	self:onSelect()
end

function _M:setupInput()
	self.mouse:reset()
	self.key:reset()
	local colx = 0

	for i=1, #self.columns do
		local col = self.columns[i]
		local on_left = function(button, x, y, xrel, yrel, bx, by, event)
			if button == "left" and event == "button" then self:selectColumn(i) end
		end
		self.mouse:registerZone(colx, 0, col.width, self.row_height, on_left, nil, ("column header%d"):format(i))
		colx = colx + col.width
	end

	local on_mouse = function(button, x, y, xrel, yrel, bx, by, event)
		self.last_input_was_keyboard = false
		if button == "wheelup" and event == "button" then self.last_input_was_keyboard = false if self.scrollbar then self.scroll_inertia = math.min(self.scroll_inertia, 0) - 5 end
		elseif button == "wheeldown" and event == "button" then self.last_input_was_keyboard = false if self.scrollbar then self.scroll_inertia = math.max(self.scroll_inertia, 0) + 5 end
		end
		if button == "middle" and self.scrollbar then
			if not self.scroll_drag then
				self.scroll_drag = true
				self.scroll_drag_x_start = x
				self.scroll_drag_y_start = y
			else
				self.scrollbar.pos = util.minBound(self.scrollbar.pos + y - self.scroll_drag_y_start, 0, self.scrollbar.max)
				self.scroll_drag_x_start = x
				self.scroll_drag_y_start = y
			end
		else
			self.scroll_drag = false
		end

		if (self.all_clicks or button == "left") and event == "button" then
			if self.click_select then
				if self.prevclick == self.sel then self:onUse(button, event) end
				self:onSelect()
				self.prevclick = self.sel
			else
				self:onUse(button, event)
			end
		end
		if event == "motion" and button == "left" and self.on_drag then self.on_drag(self.list[self.sel], self.sel) end
		if button == "drag-end" and self.on_drag_end then self.on_drag_end(self.list[self.sel], self.sel) end
		self.mouse_pos = { x = bx, y = by }
	end

	self.mouse:registerZone(0, self.row_height, self.w, self.h, on_mouse, nil, "list area")
	self.key:addBinds{
		ACCEPT = function() self.last_input_was_keyboard = true self:onUse("left", "key") end,
		MOVE_UP = function()
			self.last_input_was_keyboard = true
			self.prevrow = self.sel
			self.sel = util.minBound(self.sel - 1, 1, #self.list) end,
		MOVE_DOWN = function()
			self.last_input_was_keyboard = true
			self.prevrow = self.sel
			self.sel = util.minBound(self.sel + 1, 1, #self.list) end,
	}

	self.key:addCommands{
		[{"_UP","ctrl"}] = function() self.last_input_was_keyboard = false if self.scrollbar then self.scroll_inertia = math.min(self.scroll_inertia, 0) - 5 end end,
		[{"_DOWN","ctrl"}] = function() self.last_input_was_keyboard = false if self.scrollbar then self.scroll_inertia = math.max(self.scroll_inertia, 0) + 5 end end,
		_HOME = function()
			self.last_input_was_keyboard = true
			self.sel = 1
			self.scrollbar.pos = 0
			self:onSelect()
		end,
		_END = function()
			self.last_input_was_keyboard = true
			self.sel = self.list and #self.list or 1
			self.scrollbar.pos = self.scrollbar.max
			self:onSelect()
		end,
		_PAGEUP = function()
			self.last_input_was_keyboard = false
			if self.scrollbar then
				local scrollby = self.h - (self.only_display and 0 or (self.hide_columns and 0 or (self.floating_headers and self.max_h_columns or 0)))
				self.scrollbar.pos = util.minBound(self.scrollbar.pos - scrollby, 0, self.scrollbar.max)
			end
		end,
		_PAGEDOWN = function()
			self.last_input_was_keyboard = false
			if self.scrollbar then
				local scrollby = self.h - (self.only_display and 0 or (self.hide_columns and 0 or (self.floating_headers and self.max_h_columns or 0)))
				self.scrollbar.pos = util.minBound(self.scrollbar.pos + scrollby, 0, self.scrollbar.max)
			end
		end,
	}
end

function _M:generateRow(row, force)
	local max_h = 0
	row.cells = {}
	for j=1, #self.columns do
		local col = self.columns[j]
		row.cells[j] = row.cells[j] or {}

		-- if color for each column is different
		if row.color and type(row.color[1]) == "table" then
			color = row.color[j]
			row.cells[j].color = color
		else
			row.color = row.color or {255,255,255}
		end

		if not row.cells[j]._tex then
			if col.direct_draw then
				row.cells[j].w, row.cells[j].h = col.direct_draw(row, 0, 0, col.width, self.row_height, 0, 0, 0, 0, self.dest_area) or self.row_height, self.row_height
			else
				if type(col.display_prop) == "function" then
					text = col.display_prop(row)
				else
					text = row[col.display_prop or col.sort]
				end
				if type(text) ~= "table" or not text.is_tstring then
					text = util.getval(text, row)
					if type(text) ~= "table" then text = tstring.from(tostring(text)) end
				end

				if text.is_tstring then
					gen = self.font:draw(text:toString(), text:maxWidth(self.font), 255, 255, 255)
				else
					gen = self.font:draw(text, text:toTString():maxWidth(self.font), 255, 255, 255)
				end

				row.cells[j]._tex, row.cells[j]._tex_w, row.cells[j]._tex_h, row.cells[j].w, row.cells[j].h = gen[1]._tex, gen[1]._tex_w, gen[1]._tex_h, gen[1].w, gen[1].h

				if row.cells[j].w > col.width - 2 * col.frame_sel.b4.w then
					row.cells[j].display_offset = { x = 0, x_dir = 0 }
				end
			end
		end
		if row.cells[j].h > max_h then max_h = row.cells[j].h end
	end
	row.h = self.row_height or max_h
end

function _M:drawRow(row, row_i, nb_keyframes, x, y, total_w, total_h, loffset_x, loffset_y, dest_area)
	nb_keyframes = (nb_keyframes or 0) * 0.5
	dest_area = dest_area or self.dest_area
	local column_w_offset = x
	local clip_y_start = 0
	local clip_y_end = 0
	local clip_x_start = 0
	local clip_x_end = 0
	local clip_maxy_start = 0
	local clip_maxy_end = 0
	local clip_maxx_start = 0
	local clip_maxx_end = 0
	local frame_clip_y = 0

	local one_by_white = 1/255

	for j = 1, #self.columns do
		col = self.columns[j]
		clip_y_start = 0
		clip_y_end = 0

		-- if we only want to display content without being able to select etc.
		if not self.only_display then
			if self.sel == row_i then
				if self.focused then
					self:drawFrame(col.frame_sel, column_w_offset, y, nil, nil, nil, nil, nil, nil, 0, total_h, 0, loffset_y, dest_area)
				else
					self:drawFrame(col.frame_usel, column_w_offset, y, nil, nil, nil, nil, nil, nil, 0, total_h, 0, loffset_y, dest_area)
				end
			else
				if row.focus_decay then
					if self.focused then self:drawFrame(col.frame_sel, column_w_offset, y, 1, 1, 1, row.focus_decay * self.one_by_focus_decay, nil, nil, 0, total_h, 0, loffset_y, dest_area)
					else self:drawFrame(col.frame_usel, column_w_offset, y, 1, 1, 1, row.focus_decay * self.one_by_focus_decay, nil, nil, 0, total_h, 0, loffset_y, dest_area) end
				else
					self:drawFrame(col.frame, column_w_offset, y, nil, nil, nil, nil, nil, nil, 0, total_h, 0, loffset_y, dest_area)
				end
			end

			if row.special_bg then
				local c = row.special_bg
				if type(c) == "function" then c = c(row) end
				if c then
					self:drawFrame(col.frame_special, column_w_offset, y, c.r, c.g, c.b, c.a or 1, nil, nil, 0, total_h, 0, loffset_y, dest_area)
				end
			end
			if total_h < loffset_y then
				frame_clip_y = loffset_y - total_h
			end
		end

		if clip_y_start > clip_maxy_start then clip_maxy_start = clip_y_start end

		if col.direct_draw then
			_, _, clip_x_start, clip_x_end, clip_y_start, clip_y_end = col.direct_draw(row, column_w_offset, y, col.width, self.row_height, total_w, total_h, loffset_x, loffset_y, dest_area) or 0, 0, 0, 0, 0, 0
			frame_clip_y = 0
		elseif row.cells[j]._tex then
			local center_h = ( (self.row_height and self.row_height or row.cells[j].h) - row.cells[j].h) * 0.5

			-- if it started before visible area then compute its top clip, take centering into account
			if total_h + center_h < loffset_y then
				clip_y_start = loffset_y - total_h - center_h
				frame_clip_y = center_h
			end
			-- if it ended after visible area then compute its bottom clip
			if total_h + row.cells[j].h + center_h > loffset_y + dest_area.h then
			   clip_y_end = total_h + row.cells[j].h + center_h - loffset_y - dest_area.h
			end

			-- clip clipping to avoid texture display errors
			if clip_y_start > row.cells[j].h then clip_y_start = row.cells[j].h end

			local one_by_tex_h = 1 / row.cells[j]._tex_h -- precalculate for using it to multiply instead of division
			local one_by_tex_w = 1 / row.cells[j]._tex_w

			if row.cells[j].display_offset then
				if self.sel == row_i then
					-- if we are going right
					if row.cells[j].display_offset.x_dir == 0 then
						row.cells[j].display_offset.x = row.cells[j].display_offset.x + nb_keyframes
					-- if we are going left
					else
						row.cells[j].display_offset.x = row.cells[j].display_offset.x - nb_keyframes
					end

					-- if we would see too much to right then clip it and change dir
					if row.cells[j].display_offset.x >= row.cells[j].w - col.width + 2 * col.frame_sel.b4.w then
						row.cells[j].display_offset.x_dir = 1
						row.cells[j].display_offset.x = row.cells[j].w - col.width + 2 * col.frame_sel.b4.w
					-- if we would see too much to left then clip it and change dir
					elseif row.cells[j].display_offset.x <= 0 then
						row.cells[j].display_offset.x_dir = 0
						row.cells[j].display_offset.x = 0
					end
				else
					row.cells[j].display_offset.x = 0
				end
				if self.text_shadow then row.cells[j]._tex:toScreenPrecise(column_w_offset + 1 + col.frame_sel.b4.w, y + 1 + center_h - frame_clip_y, col.width - 2 * col.frame_sel.b4.w, row.cells[j].h - (clip_y_start + clip_y_end), row.cells[j].display_offset.x * one_by_tex_w, (row.cells[j].display_offset.x + col.width - 2 * col.frame_sel.b4.w) * one_by_tex_w, clip_y_start * one_by_tex_h, (row.cells[j].h - clip_y_end) * one_by_tex_h, 0, 0, 0, self.text_shadow) end
				row.cells[j]._tex:toScreenPrecise(column_w_offset + col.frame_sel.b4.w, y + center_h - frame_clip_y, col.width - 2 * col.frame_sel.b4.w, row.cells[j].h - (clip_y_start + clip_y_end), row.cells[j].display_offset.x * one_by_tex_w, (row.cells[j].display_offset.x + col.width - 2 * col.frame_sel.b4.w) * one_by_tex_w, clip_y_start * one_by_tex_h, (row.cells[j].h - clip_y_end) * one_by_tex_h, row.color[1] * one_by_white, row.color[2] * one_by_white, row.color[3] * one_by_white, 1.0 )
			else
				if self.text_shadow then row.cells[j]._tex:toScreenPrecise(column_w_offset + 1 + col.frame_sel.b4.w, y + 1 + center_h - frame_clip_y, row.cells[j].w, row.cells[j].h - (clip_y_start + clip_y_end), 0, row.cells[j].w * one_by_tex_w, clip_y_start * one_by_tex_h, (row.cells[j].h - clip_y_end) * one_by_tex_h, 0, 0, 0, self.text_shadow) end
				row.cells[j]._tex:toScreenPrecise(column_w_offset + col.frame_sel.b4.w, y + center_h - frame_clip_y, row.cells[j].w, row.cells[j].h - (clip_y_start + clip_y_end), 0, row.cells[j].w * one_by_tex_w, clip_y_start * one_by_tex_h, (row.cells[j].h - clip_y_end) * one_by_tex_h, row.color[1] * one_by_white, row.color[2] * one_by_white, row.color[3] * one_by_white, 1.0 )
			end
		end
		clip_y_start = clip_y_start + frame_clip_y
		column_w_offset = column_w_offset + col.width
		if clip_x_start > clip_maxx_start then clip_maxx_start = clip_x_start end
		if clip_x_end > clip_maxx_end then clip_maxx_end = clip_x_end end
		if clip_y_start > clip_maxy_start then clip_maxy_start = clip_y_start end
		if clip_y_end > clip_maxy_end then clip_maxy_end = clip_y_end end
	end
	return 0, 0, clip_maxy_start, clip_maxy_end
end

function _M:setColumns(columns, force)
	local w = self.w
	local col_size = #columns
	local max_h = 0

	if self.scrollbar then w = w - self.scrollbar.w end

	for i=1, col_size do
		local col = columns[i]
		if type(col.width) == "table" then
			if col.width[2] == "fixed" then
				w = w - col.width[1]
			end
		end
	end
	local colx = 0
	for i=1, col_size do
		local col = columns[i]
		if type(col.width) == "table" then
			if col.width[2] == "fixed" then
				col.width = col.width[1]
			end
		else
			col.width = w * col.width * 0.01
		end

		col.frame = self:makeFrame(nil, col.width, self.row_height)
		col.frame_special = self:makeFrame("ui/selector", col.width, self.row_height)
		col.frame_sel = self:makeFrame("ui/selector-sel", col.width, self.row_height)
		col.frame_usel = self:makeFrame("ui/selector", col.width, self.row_height)
		col.frame_col = self:makeFrame("ui/heading", col.width, self.row_height)
		col.frame_col_sel = self:makeFrame("ui/heading-sel", col.width, self.row_height)

		self.font:setStyle("bold")
		local gen = self.font:draw(col.name:toString(), col.width, 255, 255, 255)
		self.font:setStyle("normal")

		col._tex, col._tex_w, col._tex_h, col.w, col.h = gen[1]._tex, gen[1]._tex_w, gen[1]._tex_h, gen[1].w, gen[1].h
		colx = colx + col.width
		if col.h > max_h then max_h = col.h end
	end
	self.max_h_columns = self.hide_columns and 0 or (self.row_height or max_h)
	self.max_h = self.max_h_columns

	self.sel = 1
	self:selectColumn(1, true)
end

function _M:setList(list, force)
	if list and #list > 0 and (self.list ~= list or force) then
		self.list = list
		self.sel = util.minBound(self.sel, 1, #self.list)
		local oldcol = self.cur_col
		self:selectColumn(oldcol or 1, (not oldcol) and true or false, self.sort_reverse)

		self.max_h = self.max_h_columns
		for i=1, #self.list do
			local row = self.list[i]
			if self.focus_decay_max then self.list[i].focus_decay = 0 end
			self:generateRow(row)
			self.max_h = self.max_h + row.h
		end
	else
		self.list = {}
		self.sel = 1
		self.max_h = self.max_h_columns
	end
	if self.scrollbar then
		self.scrollbar.pos = 0
		self.scrollbar.max = self.max_h - self.h
	end
	self.prevrow = 0
end

function _M:changeAll(columns, list)
	self:setColumns(columns)
	self:setList(list)
	self:setupInput()
end

function _M:onSelect(force)
	if self.only_display then return end

	local row = self.list[self.sel]
	-- if not found fall back
	if not row then return end
--	self.scroll_inertia = 0
	if self.on_select then self.on_select(row, self.sel) end
end

function _M:removeRow(row_i)
	table.remove(self.list, row_i)
end

function _M:appendList(row)
	self.list[#self.list + 1] = row
	if (not self.sortable or self.only_display) and not force then return end
	local col = self.columns[self.cur_col]
	if self.sortable and not force then
		local fct = col.sort
		if type(fct) == "string" then fct = function(a, b) return a[col.sort] < b[col.sort] end end
		if self.sort_reverse and fct then local old=fct fct = function(a, b) return old(b, a) end end
		pcall(table.sort, self.list, fct)
	end
end

function _M:onUse(...)
	if #self.list == 0 or self.only_display then return end

	local row = self.list[self.sel]
	if not row then return end
	self:sound("button")
	if row.fct then row:fct(row, self.sel, ...)
	else self.fct(row, self.sel, ...) end
end

function _M:selectColumn(i, force, reverse)
	if (not self.sortable or self.only_display) and not force then return end
	local col = self.columns[i]
	if not col then return end

	if self.cur_col ~= i then
		self.cur_col = i
		self.sort_reverse = false
	else
		self.sort_reverse = not self.sort_reverse
	end
	self.sort_reverse = reverse

	if self.sortable and not force then
		local fct = col.sort
		if type(fct) == "string" then fct = function(a, b) return a[col.sort] < b[col.sort] end end
		if self.sort_reverse and fct then local old=fct fct = function(a, b) return old(b, a) end end
		pcall(table.sort, self.list, fct)
	end
end

function _M:display(x, y, nb_keyframes, screen_x, screen_y, offset_x, offset_y, local_x, local_y)
	self.last_display_x = screen_x
	self.last_display_y = screen_y

	nb_keyframes = nb_keyframes or 0
	offset_x = offset_x and offset_x or 0
	local row = 0

	if self.scrollbar then
		self.scrollbar.pos = util.minBound(self.scrollbar.pos + self.scroll_inertia, 0, self.scrollbar.max)
		if self.scroll_inertia > 0 then self.scroll_inertia = math.max(self.scroll_inertia - 1, 0)
		elseif self.scroll_inertia < 0 then self.scroll_inertia = math.min(self.scroll_inertia + 1, 0)
		end
		if self.scrollbar.pos == 0 or self.scrollbar.pos == self.scrollbar.max then self.scroll_inertia = 0 end
	end

	-- if we used keyboard then match display to input
	if self.scrollbar and self.last_input_was_keyboard then
		local columns_h = self.hide_columns and 0 or self.max_h_columns
		local mul = self.floating_headers and 2 or 1 -- if we have floating headers we have to take them into account while scrolling
		local pos = self.hide_columns and 0 or self.max_h_columns
		for i = 1, #self.list do
			row = self.list[i]
			pos = pos + row.h
			-- we've reached selected row
			if self.sel == i then
				-- check if it was visible if not go scroll over there
				if pos - mul * columns_h < self.scrollbar.pos then self.scrollbar.pos = util.minBound(pos - mul * columns_h, 0, self.scrollbar.max)
				elseif pos + columns_h > self.scrollbar.pos + self.h then self.scrollbar.pos = util.minBound(pos - self.h, 0, self.scrollbar.max)
				end
				break
			end
		end
	end
	offset_y = offset_y and offset_y or (self.scrollbar and self.scrollbar.pos or 0)
	local_x = local_x and local_x or 0
	local_y = local_y and local_y or 0

	local loffset_y = offset_y - local_y
	local current_y = 0
	local current_x = 0
	local total_h = 0
	local clip_x_start = 0
	local clip_x_end = 0
	local clip_y_start = 0
	local clip_y_end = 0
	local frame_clip_y = 0
	local dest_area = {}
	dest_area.h, dest_area.fixed = self.dest_area.h, self.dest_area.fixed
	local frame_clip_y_start, frame_clip_y_end

	local max_h = 0
	if not self.hide_columns then
		for j = 1, #self.columns do
			clip_y_end = 0
			local col = self.columns[j]
			local center_h = ( (self.row_height and self.row_height or col.h) - col.h) * 0.5

			if self.floating_headers then
				if self.cur_col == j then self:drawFrame(col.frame_col, x + current_x, y + current_y)
				else self:drawFrame(col.frame_col_sel, x + current_x, y + current_y) end
				local one_by_tex_h = 1 / col._tex_h
				col._tex:toScreenPrecise(x + current_x + col.frame_sel.b4.w, y + current_y + center_h, col.w, col.h - (clip_y_start + clip_y_end), 0, col.w / col._tex_w, clip_y_start * one_by_tex_h, (col.h - clip_y_end) * one_by_tex_h )
			elseif total_h + self.max_h_columns > loffset_y and total_h < loffset_y + dest_area.h then

				if self.cur_col == j then _, _, frame_clip_y_start, frame_clip_y_end = self:drawFrame(col.frame_col, x + current_x, y + current_y, nil, nil, nil, nil, nil, nil, 0, total_h, 0, loffset_y, dest_area)
				else _, _, frame_clip_y_start, frame_clip_y_end = self:drawFrame(col.frame_col_sel, x + current_x, y + current_y, nil, nil, nil, nil, nil, nil, 0, total_h, 0, loffset_y, dest_area) end
				self.mouse:updateZone(("column header%d"):format(j), current_x, current_y, col.width, self.row_height - frame_clip_y_start - frame_clip_y_end)

				if self.only_display then frame_clip_y = center_h else frame_clip_y = loffset_y - total_h end

				-- if its visible then compute how much of it needs to be clipped, take centering into account
				if total_h + center_h < loffset_y then
					clip_y_start = loffset_y - total_h - center_h
					frame_clip_y = center_h
				end

				-- if it ended after visible area then compute its bottom clip
				if total_h + col.h  + center_h > loffset_y + dest_area.h then
				   clip_y_end = total_h + col.h + center_h - loffset_y - dest_area.h
				end
				local one_by_tex_h = 1 / col._tex_h
				if total_h + col.h > loffset_y and total_h < loffset_y + dest_area.h then
					col._tex:toScreenPrecise(x + current_x + col.frame_sel.b4.w, y + current_y + center_h - frame_clip_y, col.w, col.h - (clip_y_start + clip_y_end), 0, col.w / col._tex_w, clip_y_start * one_by_tex_h, (col.h - clip_y_end) * one_by_tex_h )
				end
			end

			if col.h > max_h then max_h = col.h end
			current_x = current_x + col.width
		end
		max_h = self.row_height or max_h

		if self.floating_headers then
			dest_area.h = dest_area.h - max_h
			current_y = current_y + max_h
			loffset_y = loffset_y + max_h
		elseif total_h + max_h > loffset_y and total_h < loffset_y + dest_area.h then
			current_y = current_y + max_h
			if not self.only_display then current_y = current_y + total_h - loffset_y end
		end
		total_h = total_h + max_h
	end

	local list_start_y = current_y
	self.mouse:updateZone("list area", 0, current_y, self.w, self.h - current_y)

	-- if list is empty then display only column headers and fall back
	if  #self.list == 0 then return end

	-- refresh focus decay if any
	if self.focus_decay_max then self.list[self.sel].focus_decay = self.focus_decay_max end

	-- if we are too deep then end this
	if total_h > loffset_y + dest_area.h then return end
	for i = 1, #self.list do
		row = self.list[i]
		-- if its visible then draw it
		if total_h + row.h > loffset_y and total_h < loffset_y + dest_area.h then
			_, _, clip_y_start, clip_y_end = self:drawRow(row, i, nb_keyframes, x, y + current_y, 0, total_h, 0, loffset_y, dest_area)

			row.last_display_x = screen_x
			row.last_display_y = screen_y + current_y

			-- use display loop to determine which row is selected
			if not self.last_input_was_keyboard and self.mouse_pos.y + list_start_y> current_y and self.mouse_pos.y + list_start_y< current_y + row.h - clip_y_start then self.sel = i end
			current_y = current_y + row.h - clip_y_start
		end

		-- decay focus if any
		if row.focus_decay then
			row.focus_decay = row.focus_decay - nb_keyframes
			if row.focus_decay <= 0 then row.focus_decay = nil end
		end
		-- add full size of row
		total_h = total_h + row.h
		-- if we are too deep then end this
		if total_h > loffset_y + dest_area.h then break end
	end

	-- show scrollbar only if there is one, total size of UI element is greater than visible one and only_display switch is not set
	if self.focused and self.scrollbar and self.max_h > self.h and not self.only_display then
		if self.hide_columns then
			self.scrollbar:display(x + self.w - self.scrollbar.w, y)
		else
			self.scrollbar:display(x + self.w - self.scrollbar.w, y + max_h)
		end
	end

	-- if row was changed then refresh it
	if self.prevrow ~= self.sel then
		self.prevrow = self.sel
		if not self.click_select then self:onSelect() end
	end
end
