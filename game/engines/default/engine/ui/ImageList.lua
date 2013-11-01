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
local Tiles = require "engine.Tiles"
local Base = require "engine.ui.Base"
local Slider = require "engine.ui.Slider"
local Focusable = require "engine.ui.Focusable"

--- A generic UI image list
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.tile_w = assert(t.tile_w, "no image list tile width")
	self.tile_h = assert(t.tile_h, "no image list tile height")
	self.w = assert(t.width, "no image list width")
	self.h = assert(t.height, "no image list  height")
	self.list = assert(t.list, "no image list list")
	self.fct = assert(t.fct, "no image list fct")
	self.padding = t.padding or 6
	self.force_size = t.force_size
	self.scrollbar = t.scrollbar
	self.selection = t.selection
	self.on_select = t.on_select

	self.nb_w = math.floor(self.w / (self.tile_w + self.padding))
	self.nb_h = math.floor(self.h / (self.tile_h + self.padding))

	self.tiles = {}

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self.scroll = 1
	self.dlist = {}
	local row = {}
	for i, data in ipairs(self.list) do
		local f = data
		if type(data) == "table" then f = f.image end
		local s = Tiles:loadImage(f)
		if s then
			local w, h = s:getSize()
			local item = {s:glTexture()}
			item.w = w
			item.h = h
			item.f = f
			item.data = data
			self.tiles[f] = {f=f, w=w, h=h, pos_i = #row+1, pos_j = #self.dlist}
			row[#row+1] = item
			if #row + 1 > self.nb_w then
				self.dlist[#self.dlist+1] = row
				row = {}
			end
		end
	end
	self.dlist[#self.dlist+1] = row
	self.max = #self.dlist

	if self.scrollbar then
		self.scrollbar = Slider.new{size=self.h, max=#self.dlist - self.nb_h}
	end

	self.frame = self:makeFrame(nil, self.tile_w, self.tile_h)
	self.frame_sel = self:makeFrame("ui/selector-sel", self.tile_w, self.tile_h)
	self.frame_usel = self:makeFrame("ui/selector", self.tile_w, self.tile_h)
	if self.selection then
		self.frame_selected = self:makeFrame("ui/selector-green", self.tile_w, self.tile_h)
	end

	self.sel_i = 1
	self.sel_j = 1

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		if self.scrollbar then
			if button == "wheelup" and event == "button" then self.scroll = util.bound(self.scroll - 1, 1, self.scrollbar.max)
			elseif button == "wheeldown" and event == "button" then self.scroll = util.bound(self.scroll + 1, 1, self.scrollbar.max) end
		end

		self.sel_j = util.bound(self.scroll + math.floor(by / (self.tile_h + self.padding)), 1, self.max)
		self.sel_i = util.bound(1 + math.floor(bx / (self.tile_w + self.padding)), 1, self.nb_w)
		if (button == "left" or button == "right") and event == "button" then self:onUse(button) end
		self:onSelect()
	end)
	self.key:addBinds{
		ACCEPT = function() self:onUse() end,
		MOVE_UP = function()
			self.sel_j = util.boundWrap(self.sel_j - 1, 1, self.max) self.scroll = util.scroll(self.sel_j, self.scroll, self.nb_h)
			self:onSelect()
		end,
		MOVE_DOWN = function()
			self.sel_j = util.boundWrap(self.sel_j + 1, 1, self.max) self.scroll = util.scroll(self.sel_j, self.scroll, self.nb_h)
			self:onSelect()
		end,
		MOVE_RIGHT = function()
			self.sel_i = util.boundWrap(self.sel_i + 1, 1, self.nb_w)
			self:onSelect()
		end,
		MOVE_LEFT = function()
			self.sel_i = util.boundWrap(self.sel_i - 1, 1, self.nb_w)
			self:onSelect()
		end,
	}
	self.key:addCommands{
		[{"_UP","ctrl"}] = function() self.key:triggerVirtual("MOVE_UP") end,
		[{"_DOWN","ctrl"}] = function() self.key:triggerVirtual("MOVE_DOWN") end,
		_HOME = function()
			self.sel_j = 1
			self.scroll = util.scroll(self.sel_j, self.scroll, self.nb_h)
			self:onSelect()
		end,
		_END = function()
			self.sel_j = self.max
			self.scroll = util.scroll(self.sel_j, self.scroll, self.nb_h)
			self:onSelect()
		end,
		_PAGEUP = function()
			self.sel_j = util.bound(self.sel_j - self.nb_h, 1, self.max)
			self.scroll = util.scroll(self.sel_j, self.scroll, self.nb_h)
			self:onSelect()
		end,
		_PAGEDOWN = function()
			self.sel_j = util.bound(self.sel_j + self.nb_h, 1, self.max)
			self.scroll = util.scroll(self.sel_j, self.scroll, self.nb_h)
			self:onSelect()
		end,
	}
end

function _M:getAllSelected()
	local list = {}
	for i, row in ipairs(self.dlist) do for j, item in ipairs(row) do if item.selected then list[#list+1] = item end end end
	return list
end

function _M:getAllSelectedKeys()
	local list = {}
	for i, row in ipairs(self.dlist) do for j, item in ipairs(row) do if item.selected then list[#list+1] = {i,j} end end end
	return list
end

function _M:clearSelection()
	for i, row in ipairs(self.dlist) do for j, item in ipairs(row) do item.selected = false end end
end

function _M:onUse(button, forcectrl)
	local item = self.dlist[self.sel_j] and self.dlist[self.sel_j][self.sel_i]
	self:sound("button")
	if item then
		if self.selection == "simple" then
			self:clearSelection()
			item.selected = not item.selected
		elseif self.selection == "multiple" then
			item.selected = not item.selected
		elseif self.selection == "ctrl-multiple" then
			if not (forcectrl == true or (forcectrl == nil and core.key.modState("ctrl"))) then self:clearSelection() end
			item.selected = not item.selected
		end
		self.fct(item, button)
	end
end

function _M:onSelect(how, force)
	local item = self.dlist[self.sel_j] and self.dlist[self.sel_j][self.sel_i]
	if self.prev_item == item and not force then return end
	if self.on_select and item then self.on_select(item, how) end
	self.prev_item = item
end

function _M:display(x, y, nb_keyframes, screen_x, screen_y)
	local bx, by = x, y

	for j = self.scroll, math.min(self.scroll + self.nb_h, #self.dlist) do
		local row = self.dlist[j]
		if row then for i = 1, #row do
			local item = row[i]

			if item.selected then self:drawFrame(self.frame_selected, x + (i-1) * (self.tile_w + self.padding), y) end

			if self.sel_i == i and self.sel_j == j then
				if self.focused then self:drawFrame(self.frame_sel, x + (i-1) * (self.tile_w + self.padding), y)
				else self:drawFrame(self.frame_usel, x + (i-1) * (self.tile_w + self.padding), y) end
			else
				self:drawFrame(self.frame, x + (i-1) * (self.tile_w + self.padding), y)
			end

			if self.force_size then
				item[1]:toScreenFull(x + (i-1) * (self.tile_w + self.padding), y, self.tile_w, self.tile_h, item[2] * self.tile_w / item.w, item[3] * self.tile_h / item.h)
			else
				item[1]:toScreenFull(x + (i-1) * (self.tile_w + self.padding) + self.tile_w - item.w, y + self.tile_h - item.h, item.w, item.h, item[2], item[3])
			end
			item.last_display_x = screen_x + (x - bx)
			item.last_display_y = screen_y + (y - by)
		end end
		y = y + self.tile_h + self.padding
	end

	if self.focused and self.scrollbar then
		self.scrollbar.pos = self.scroll
		self.scrollbar:display(bx + self.w - self.scrollbar.w, by)
	end
end
