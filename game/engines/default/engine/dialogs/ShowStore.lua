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
local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(title, store_inven, actor_inven, store_filter, actor_filter, action, desc)
	self.action = action
	self.desc = desc
	self.store_inven = store_inven
	self.actor_inven = actor_inven
	self.store_filter = store_filter
	self.actor_filter = actor_filter
	Dialog.init(self, title or "Store", game.w * 0.8, game.h * 0.8)

	self:generateList()

	self.c_inven = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.max_h*self.font_h - 10, sortable=true, scrollbar=true, columns={
		{name="", width={20,"fixed"}, display_prop="char", sort="id"},
		{name="Inventory", width=72, display_prop="name", sort="name"},
		{name="Category", width=20, display_prop="cat", sort="cat"},
		{name="Price", width=8, display_prop="cost", sort="cost"},
	}, list=self.actor_list, fct=function(item, sel) self:use(item) end, select=function(item, sel) self:select(item) end}

	self.c_store = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.max_h*self.font_h - 10, sortable=true, scrollbar=true, columns={
		{name="", width={20,"fixed"}, display_prop="char", sort="id"},
		{name="Store", width=72, display_prop="name"},
		{name="Category", width=20, display_prop="cat"},
		{name="Price", width=8, display_prop="cost", sort="cost"},
	}, list=self.store_list, fct=function(item) self:use(item) end, select=function(item, sel) self:select(item) end}

	self.c_desc = Textzone.new{width=self.iw, height=self.max_h*self.font_h, no_color_bleed=true, text=""}

	self:loadUI{
		{left=0, top=0, ui=self.c_store},
		{right=0, top=0, ui=self.c_inven},
		{left=0, bottom=0, ui=self.c_desc},
		{hcenter=0, top=5, ui=Separator.new{dir="horizontal", size=self.ih - self.c_desc.h - 10}},
		{left=5, bottom=self.c_desc.h, ui=Separator.new{dir="vertical", size=self.iw - 10}},
	}
	self:setFocus(self.c_inven)
	self:setupUI()

	self.key:addCommands{
		__TEXTINPUT = function(c)
			local list
			if self.focus_ui and self.focus_ui.ui == self.c_inven then list = self.c_inven.list
			elseif self.focus_ui and self.focus_ui.ui == self.c_store then list = self.c_store.list
			end
			if list and list.chars[c] then
				self:use(list[list.chars[c]])
			end
		end,
	}
	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:updateStore()
	self:generateList()
end

function _M:select(item)
	if item and self.uis[3] then
		self.uis[3].ui = item.zone
	end
end

function _M:use(item)
	if item and item.object then
		if self.focus_ui and self.focus_ui.ui == self.c_store then
			self.action("buy", item.object, item.item)
			self:updateStore()
		else
			self.action("sell", item.object, item.item)
			self:updateStore()
		end
	end
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	list.chars = {}
	local i = 1
	self.max_h = 0
	for item, o in ipairs(self.store_inven) do
		if not self.store_filter or self.store_filter(o) then
			local char = self:makeKeyChar(i)
			local zone = self.c_desc:spawn{text=o:getDesc()}
			list[#list+1] = { zone=zone, id=#list+1, char=char, name=o:getDisplayString()..o:getName(), color=o:getDisplayColor(), object=o, item=item, cat=o.subtype, cost=o.cost }
			self.max_h = math.max(self.max_h, #o:getDesc():splitLines(self.iw - 10, self.font))
			list.chars[char] = #list
			i = i + 1
		end
	end
	self.store_list = list

	-- Makes up the list
	local list = {}
	list.chars = {}
	local i = 1
	for item, o in ipairs(self.actor_inven) do
		if not self.actor_filter or self.actor_filter(o) then
			local char = self:makeKeyChar(i)
			local zone = self.c_desc:spawn{text=o:getDesc()}
			list[#list+1] = { zone=zone, id=#list+1, char=char, name=o:getDisplayString()..o:getName(), color=o:getDisplayColor(), object=o, item=item, cat=o.subtype, cost=o.cost }
			self.max_h = math.max(self.max_h, #o:getDesc():splitLines(self.iw - 10, self.font))
			list.chars[char] = #list
			i = i + 1
		end
	end
	self.actor_list = list

	if self.c_inven then
		self.c_inven.list = self.actor_list
		self.c_store.list = self.store_list
		self.c_inven:generate()
		self.c_store:generate()
	end
end
