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

	local w = self.w
	if self.scrollbar then w = w - 10 end
	for j, col in ipairs(self.columns) do
		col.width = w * col.width / 100
	end

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self.sel = 1
	self.scroll = 1
	self.max = #self.list
	self:selectColumn(1, true)

	local ls, ls_w, ls_h = self:getImage("ui/selection-left-sel.png")
	local ms, ms_w, ms_h = self:getImage("ui/selection-middle-sel.png")
	local rs, rs_w, rs_h = self:getImage("ui/selection-right-sel.png")
	local l, l_w, l_h = self:getImage("ui/selection-left.png")
	local m, m_w, m_h = self:getImage("ui/selection-middle.png")
	local r, r_w, r_h = self:getImage("ui/selection-right.png")

	local cls, cls_w, cls_h = self:getImage("ui/selection-left-column-sel.png")
	local cms, cms_w, cms_h = self:getImage("ui/selection-middle-column-sel.png")
	local crs, crs_w, crs_h = self:getImage("ui/selection-right-column-sel.png")
	local cl, cl_w, cl_h = self:getImage("ui/selection-left-column.png")
	local cm, cm_w, cm_h = self:getImage("ui/selection-middle-column.png")
	local cr, cr_w, cr_h = self:getImage("ui/selection-right-column.png")


	local fh = ls_h
	self.fh = fh

	if not self.h then self.h = self.nb_items * fh end

	self.max_display = math.floor(self.h / fh) - 1

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

	-- Draw the list columns
	local colx = 0
	for j, col in ipairs(self.columns) do
		local fw = col.width
		col.fw = fw
		local text = col.name
		local ss = core.display.newSurface(fw, fh)
		local s = core.display.newSurface(fw, fh)

		self.font:setStyle("bold")
		ss:merge(cls, 0, 0)
		for i = cls_w, fw - crs_w do ss:merge(cms, i, 0) end
		ss:merge(crs, fw - crs_w, 0)
		ss:drawColorStringBlended(self.font, text, cls_w, (fh - self.font_h) / 2, 255, 255, 255, nil, fw - cls_w - crs_w)

		s:merge(cl, 0, 0)
		for i = cl_w, fw - cr_w do s:merge(cm, i, 0) end
		s:merge(cr, fw - cr_w, 0)
		s:drawColorStringBlended(self.font, text, cl_w, (fh - self.font_h) / 2, 255, 255, 255, nil, fw - cl_w - cr_w)
		self.font:setStyle("normal")

		col._tex, col._tex_w, col._tex_h = s:glTexture()
		col._stex = ss:glTexture()

		-- Draw the list items
		for i, item in ipairs(self.list) do
			local text = tostring(item[col.display_prop or col.sort])
			local color = item.color or {255,255,255}
			local ss = core.display.newSurface(fw, fh)
			local sus = core.display.newSurface(fw, fh)
			local s = core.display.newSurface(fw, fh)

			ss:merge(ls, 0, 0)
			for i = ls_w, fw - rs_w do ss:merge(ms, i, 0) end
			ss:merge(rs, fw - rs_w, 0)
			ss:drawColorStringBlended(self.font, text, ls_w, (fh - self.font_h) / 2, color[1], color[2], color[3], nil, fw - ls_w - rs_w)

			s:erase(0, 0, 0)
			s:drawColorStringBlended(self.font, text, ls_w, (fh - self.font_h) / 2, color[1], color[2], color[3], nil, fw - ls_w - rs_w)

			sus:merge(l, 0, 0)
			for i = l_w, fw - r_w do sus:merge(m, i, 0) end
			sus:merge(r, fw - r_w, 0)
			sus:drawColorStringBlended(self.font, text, ls_w, (fh - self.font_h) / 2, color[1], color[2], color[3], nil, fw - ls_w - rs_w)

			item._tex = item._tex or {}
			item._stex = item._stex or {}
			item._sustex = item._sustex or {}
			item._tex[j] = {s:glTexture()}
			item._stex[j] = {ss:glTexture()}
			item._sustex[j] = {sus:glTexture()}
		end

		self.mouse:registerZone(colx, 0, col.width, self.fh, function(button, x, y, xrel, yrel, bx, by, event)
			if button == "left" and event == "button" then self:selectColumn(j) end
		end)
		colx = colx + col.width
	end

	-- Add UI controls
	self.mouse:registerZone(0, self.fh, self.w, self.h - self.fh, function(button, x, y, xrel, yrel, bx, by, event)
		if button == "wheelup" and event == "button" then self.scroll = util.bound(self.scroll - 1, 1, self.max - self.max_display + 1)
		elseif button == "wheeldown" and event == "button" then self.scroll = util.bound(self.scroll + 1, 1, self.max - self.max_display + 1) end

		self.sel = util.bound(self.scroll + math.floor(by / self.fh), 1, self.max)
		self:onSelect()
		if (self.all_clicks or button == "left") and event == "button" then self:onUse(button) end
	end)
	self.key:addBinds{
		ACCEPT = function() self:onUse() end,
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, self.max) self.scroll = util.scroll(self.sel, self.scroll, self.max_display) self:onSelect() end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, self.max) self.scroll = util.scroll(self.sel, self.scroll, self.max_display) self:onSelect() end,
	}
	self.key:addCommands{
		_HOME = function()
			self.sel = 1
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
			self:onSelect()
		end,
		_END = function()
			self.sel = self.max
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
			self:onSelect()
		end,
		_PAGEUP = function()
			self.sel = util.bound(self.sel - self.max_display, 1, self.max)
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
			self:onSelect()
		end,
		_PAGEDOWN = function()
			self.sel = util.bound(self.sel + self.max_display, 1, self.max)
			self.scroll = util.scroll(self.sel, self.scroll, self.max_display)
			self:onSelect()
		end,
	}

	self:onSelect()
end

function _M:onSelect()
	local item = self.list[self.sel]
	if not item then return end

	if rawget(self, "select") then self.select(item, self.sel) end
end

function _M:onUse()
	local item = self.list[self.sel]
	if not item then return end
	if item.fct then item:fct()
	else self.fct(item, self.sel) end
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

function _M:display(x, y)
	local bx, by = x, y

	for j = 1, #self.columns do
		local col = self.columns[j]
		if self.cur_col == j then
			col._stex:toScreenFull(x, y, col.fw, self.fh, col._tex_w, col._tex_h)
		else
			col._tex:toScreenFull(x, y, col.fw, self.fh, col._tex_w, col._tex_h)
		end

		local y = y + self.fh
		local max = math.min(self.scroll + self.max_display - 1, self.max)
		for i = self.scroll, max do
			local item = self.list[i]
			if not item then break end
			if self.sel == i then
				if self.focused then
					item._stex[j][1]:toScreenFull(x, y, col.fw, self.fh, item._stex[j][2], item._stex[j][3])
				else
					item._sustex[j][1]:toScreenFull(x, y, col.fw, self.fh, item._sustex[j][2], item._sustex[j][3])
				end
			else
				item._tex[j][1]:toScreenFull(x, y, col.fw, self.fh, item._tex[j][2], item._tex[j][3])
			end
			y = y + self.fh
		end

		x = x + col.width
	end

	if self.focused and self.scrollbar then
		local pos = self.sel * (self.h - self.fh) / self.max

		self.scrollbar.bar.tex:toScreenFull(bx + self.w - self.scrollbar.bar.w, by + self.fh, self.scrollbar.bar.w, self.scrollbar.bar.h, self.scrollbar.bar.texw, self.scrollbar.bar.texh)
		self.scrollbar.sel.tex:toScreenFull(bx + self.w - self.scrollbar.sel.w, by + self.fh + pos, self.scrollbar.sel.w, self.scrollbar.sel.h, self.scrollbar.sel.texw, self.scrollbar.sel.texh)
	end
end
