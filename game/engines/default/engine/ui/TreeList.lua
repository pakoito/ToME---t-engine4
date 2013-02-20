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
local Slider = require "engine.ui.Slider"

--- A generic UI list
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.tree = assert(t.tree, "no tree tree")
	self.columns = assert(t.columns, "no list columns")
	self.w = assert(t.width, "no tree width")
	self.h = t.height
	self.nb_items = t.nb_items
	assert(self.h or self.nb_items, "no tree height/nb_items")
	self.fct = t.fct
	self.on_drag = t.on_drag
	self.on_expand = t.on_expand
	self.on_drawitem = t.on_drawitem
	self.select = t.select
	self.scrollbar = t.scrollbar
	self.all_clicks = t.all_clicks
	self.level_offset = t.level_offset or 12
	self.key_prop = t.key_prop or "__id"
	self.sel_by_col = t.sel_by_col and {} or nil

	self.fh = t.item_height or (self.font_h + 6)

	self.plus = _M:getUITexture("ui/plus.png")
	self.minus = _M:getUITexture("ui/minus.png")

	local w = self.w
	if self.scrollbar then w = w - 10 end
	local colw = 0
	for j, col in ipairs(self.columns) do
		if type(col.width) == "table" then
			if col.width[2] == "fixed" then
				w = w - col.width[1]
			end
		end
	end
	for j, col in ipairs(self.columns) do
		col.id = j
		if type(col.width) == "table" then
			if col.width[2] == "fixed" then
				col.width = col.width[1]
			end
		else
			col.width = w * col.width / 100
		end
		if self.sel_by_col then
			colw = colw + col.width
			self.sel_by_col[j] = colw
		end

		col.surface = core.display.newSurface(col.width, self.fh)
		col.frame = self:makeFrame(nil, col.width, self.fh)
		col.frame_sel = self:makeFrame("ui/selector-sel", col.width, self.fh)
		col.frame_usel = self:makeFrame("ui/selector", col.width, self.fh)
		col.frame_col = self:makeFrame("ui/selector", col.width, self.fh)
		col.frame_col_sel = self:makeFrame("ui/selector-sel", col.width, self.fh)

		col._backs = {}
	end

	self.items_by_key = {}

	Base.init(self, t)
end

function _M:drawItem(item, nb_keyframes)
	nb_keyframes = (nb_keyframes or 0) / 2
	item.cols = {}
	for i, col in ipairs(self.columns) do
		if not col.direct_draw then
			local fw = col.width
			local level = item.level
			local color = util.getval(item.color, item) or {255,255,255}
			local text
			if type(col.display_prop) == "function" then
				text = col.display_prop(item):toTString()
			else
				text = item[col.display_prop or col.sort]
				if type(text) ~= "table" or not text.is_tstring then
					text = util.getval(text, item)
					if type(text) ~= "table" then text = tstring.from(tostring(text)) end
				end
			end
			local s = col.surface

			local offset = 0
			if i == 1 then
				offset = level * self.level_offset
				if item.nodes then offset = offset + self.plus.w end
			end
			local startx = col.frame_sel.b4.w + offset

			item.cols[i] = {}

			s:erase(0, 0, 0, 0)
			local test_text = text:toString()
			local font_w, _ = self.font:size(test_text)
			font_w = font_w + startx

			if font_w > fw then
				item.displayx_offset = item.displayx_offset or {}
				item.displayx_offset[i] = item.displayx_offset[i] or 0
				item.dir = item.dir or {}
				item.dir[i] = item.dir[i] or 0

				if item.dir[i] == 0 then
					item.displayx_offset[i] = item.displayx_offset[i] - nb_keyframes
					if -item.displayx_offset[i] >= font_w - fw + 15 then
						item.dir[i] = 1
					end
				elseif item.dir[i] == 1 then
					item.displayx_offset[i] = item.displayx_offset[i] + nb_keyframes
					if item.displayx_offset[i] >= 0 then
						item.dir[i] = 0
					end
				end

				-- We use 1000 and do not cut lines to make sure it draws as much as possible
				text:drawOnSurface(s, 10000, nil, self.font, startx + item.displayx_offset[i], (self.fh - self.font_h) / 2, color[1], color[2], color[3])
				item.autoscroll = true
			else
				text:drawOnSurface(s, 10000, nil, self.font, startx, (self.fh - self.font_h) / 2, color[1], color[2], color[3])
			end

			--text:drawOnSurface(s, col.width - startx - col.frame_sel.b6.w, 1, self.font, startx, (self.fh - self.font_h) / 2, color[1], color[2], color[3])
			item.cols[i]._tex, item.cols[i]._tex_w, item.cols[i]._tex_h = s:glTexture()
		end
	end
	if self.on_drawitem then self.on_drawitem(item) end
end

function _M:drawTree()
	local recurs recurs = function(list, level)
		for i, item in ipairs(list) do
			item.level = level
			if item[self.key_prop] then self.items_by_key[item[self.key_prop]] = item end
			self:drawItem(item)
			if item.nodes then recurs(item.nodes, level+1) end
		end
	end
	recurs(self.tree, 0)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	local fw, fh = self.w, self.fh
	self.fw, self.fh = fw, fh

	if not self.h then self.h = self.nb_items * fh end

	self.max_display = math.floor(self.h / fh)

	-- Draw the scrollbar
	if self.scrollbar then
		self.scrollbar = Slider.new{size=self.h - fh, max=1}
	end

	-- Draw the tree items
	self:drawTree()

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		if button == "wheelup" and event == "button" then self.scroll = util.bound(self.scroll - 1, 1, self.max - self.max_display + 1)
		elseif button == "wheeldown" and event == "button" then self.scroll = util.bound(self.scroll + 1, 1, self.max - self.max_display + 1) end

			if self.sel and self.list[self.sel] then self.list[self.sel].focus_decay = self.focus_decay_max end
		self.sel = util.bound(self.scroll + math.floor(by / self.fh), 1, self.max)
		if self.sel_by_col then
			for i = 1, #self.sel_by_col do if bx > (self.sel_by_col[i-1] or 0) and bx <= self.sel_by_col[i] then
				self.cur_col = i
				break
			end end
		end
		self:onSelect()
		if self.list[self.sel] and self.list[self.sel].nodes and bx <= self.plus.w and button ~= "wheelup" and button ~= "wheeldown" and event == "button" then
			self:treeExpand(nil)
		else
			if (self.all_clicks or button == "left") and button ~= "wheelup" and button ~= "wheeldown" and event == "button" then self:onUse(button) end
		end
		if event == "motion" and button == "left" and self.on_drag then self.on_drag(self.list[self.sel], self.sel) end
	end)
	self.key:addBinds{
		ACCEPT = function() self:onUse("left") end,
		MOVE_UP = function()
			if self.sel and self.list[self.sel] then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = util.boundWrap(self.sel - 1, 1, self.max) self.scroll = util.scroll(self.sel, self.scroll, self.max_display) self:onSelect()
		end,
		MOVE_DOWN = function()
			if self.sel and self.list[self.sel] then self.list[self.sel].focus_decay = self.focus_decay_max end
			self.sel = util.boundWrap(self.sel + 1, 1, self.max) self.scroll = util.scroll(self.sel, self.scroll, self.max_display) self:onSelect()
		end,
	}
	if self.sel_by_col then
		self.key:addBinds{
			MOVE_LEFT = function() self.cur_col = util.boundWrap(self.cur_col - 1, 1, #self.sel_by_col) self:onSelect() end,
			MOVE_RIGHT = function() self.cur_col = util.boundWrap(self.cur_col + 1, 1, #self.sel_by_col) self:onSelect() end,
		}
	end
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

	self:outputList()
	self:onSelect()
end

function _M:outputList()
	local flist = {}
	self.list = flist

	local recurs recurs = function(list)
		for i, item in ipairs(list) do
			flist[#flist+1] = item
			if item.nodes and item.shown then recurs(item.nodes) end
		end
	end
	recurs(self.tree)

	self.max = #self.list
	self.sel = util.bound(self.sel or 1, 1, self.max)
	self.scroll = self.scroll or 1
	self.cur_col = self.cur_col or 1
end

function _M:treeExpand(v, item)
	local item = item or self.list[self.sel]
	if not item then return end
	if v == nil then
		item.shown = not item.shown
	else
		item.shown = v
	end
	if self.on_expand then self.on_expand(item) end
	self:drawItem(item)
	self:outputList()
end

function _M:onSelect()
	local item = self.list[self.sel]
	if not item then return end
	if self.old_sel and self.sel == self.old_sel then return end

	if rawget(self, "select") then self.select(item, self.sel) end

	self.old_sel = self.sel
end

function _M:onUse(...)
	local item = self.list[self.sel]
	if not item then return end
	self:sound("button")
	if item.fct then item.fct(item, self.sel, ...)
	else self.fct(item, self.sel, ...) end
end

function _M:display(x, y, nb_keyframes)
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

	local max = math.min(self.scroll + self.max_display - 1, self.max)
	for i = self.scroll, max do
		local x = x
		for j = 1, #self.columns do
			local col = self.columns[j]
			local item = self.list[i]
			if not item then break end
			if self.sel == i and (not self.sel_by_col or self.cur_col == j) then
				if self.focused then self:drawFrame(col.frame_sel, x, y)
				else self:drawFrame(col.frame_usel, x, y) end
			elseif (not self.sel_by_col or self.cur_col == j) then
				self:drawFrame(col.frame, x, y)
				if item.focus_decay then
					if self.focused then self:drawFrame(col.frame_sel, x, y, 1, 1, 1, item.focus_decay / self.focus_decay_max_d)
					else self:drawFrame(col.frame_usel, x, y, 1, 1, 1, item.focus_decay / self.focus_decay_max_d) end
					item.focus_decay = item.focus_decay - nb_keyframes
					if item.focus_decay <= 0 then item.focus_decay = nil end
				end
			end

			if col.direct_draw then
				col.direct_draw(item, x, y, col.width, self.fh)
			else
				if self.text_shadow then item.cols[j]._tex:toScreenFull(x+1, y+1, col.width, self.fh, item.cols[j]._tex_w, item.cols[j]._tex_h, 0, 0, 0, self.text_shadow) end
				item.cols[j]._tex:toScreenFull(x, y, col.width, self.fh, item.cols[j]._tex_w, item.cols[j]._tex_h)
			end

			if item.nodes and j == 1 then
				local s = item.shown and self.minus or self.plus
				s.t:toScreenFull(x, y + (self.fh - s.h) / 2, s.w, s.h, s.th, s.th)
			end

			x = x + col.width
		end
		y = y + self.fh
	end

	if self.focused and self.scrollbar then
		self.scrollbar.pos = self.sel
		self.scrollbar.max = self.max
		self.scrollbar:display(bx + self.w - self.scrollbar.w, by, by + self.fh)
	end
end
