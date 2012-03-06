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
local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(title, store_inven, actor_inven, store_filter, actor_filter, action, desc, descprice, allow_sell, allow_buy, on_select)
	self.on_select = on_select
	self.allow_sell, self.allow_buy = allow_sell, allow_buy
	self.action = action
	self.desc = desc
	self.descprice = descprice
	self.store_inven = store_inven
	self.actor_inven = actor_inven
	self.store_filter = store_filter
	self.actor_filter = actor_filter
	Dialog.init(self, title or "Store", math.max(800, game.w * 0.8), math.max(600, game.h * 0.8))

	self.c_inven = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, sortable=true, scrollbar=true, columns={
		{name="", width={20,"fixed"}, display_prop="char", sort="id"},
		{name="", width={24,"fixed"}, display_prop="object", direct_draw=function(item, x, y) item.object:toScreen(nil, x+4, y, 16, 16) end},
		{name="Inventory", width=80, display_prop="name", sort="name"},
		{name="Category", width=20, display_prop="cat", sort="cat"},
		{name="Price", width={50,"fixed"}, display_prop="desc_price", sort=function(a, b) return descprice("sell", a.object) <descprice("sell", b.object) end},
	}, list={}, fct=function(item, sel) self:use(item) end, select=function(item, sel) self:select(item) end}

	self.c_store = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, sortable=true, scrollbar=true, columns={
		{name="", width={20,"fixed"}, display_prop="char", sort="id"},
		{name="", width={24,"fixed"}, display_prop="object", direct_draw=function(item, x, y) item.object:toScreen(nil, x+4, y, 16, 16) end},
		{name="Store", width=80, display_prop="name"},
		{name="Category", width=20, display_prop="cat"},
		{name="Price", width={50,"fixed"}, display_prop="desc_price", sort=function(a, b) return descprice("buy", a.object) <descprice("buy", b.object) end},
	}, list={}, fct=function(item) self:use(item) end, select=function(item, sel) self:select(item) end}

	self:generateList()

	self:loadUI{
		{left=0, top=0, ui=self.c_store},
		{right=0, top=0, ui=self.c_inven},
		{hcenter=0, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
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

function _M:on_register()
	game:onTickEnd(function() self.key:unicodeInput(true) end)
end

function _M:updateStore()
	self:generateList()
end

function _M:select(item)
	if self.cur_item == item then return end
	if item then
		if self.on_select then self.on_select(item) end
	end
	self.cur_item = item
end

function _M:on_focus(id, ui)
	if self.focus_ui and self.focus_ui.ui == self.c_inven then self:select(self.c_inven.list[self.c_inven.sel])
	elseif self.focus_ui and self.focus_ui.ui == self.c_store then self:select(self.c_store.list[self.c_store.sel])
	end
end

function _M:use(item)
	if item and item.object then
		if self.focus_ui and self.focus_ui.ui == self.c_store then
			if util.getval(self.allow_buy, item.object, item.item) then
				self.action("buy", item.object, item.item)
			end
		else
			if util.getval(self.allow_sell, item.object, item.item) then
				self.action("sell", item.object, item.item)
			end
		end
	end
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	list.chars = {}
	local i = 1
	for item, o in ipairs(self.store_inven) do
		if not self.store_filter or self.store_filter(o) then
			local char = self:makeKeyChar(i)
			list[#list+1] = { id=#list+1, char=char, name=o:getName(), color=o:getDisplayColor(), object=o, item=item, cat=o.subtype, cost=o.cost, desc=o:getDesc(), desc_price=self.descprice("buy", o) }
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
			list[#list+1] = { id=#list+1, char=char, name=o:getName(), color=o:getDisplayColor(), object=o, item=item, cat=o.subtype, cost=o.cost, desc=o:getDesc(), desc_price=self.descprice("sell", o) }
			list.chars[char] = #list
			i = i + 1
		end
	end
	self.actor_list = list

	self.c_inven:setList(self.actor_list)
	self.c_store:setList(self.store_list)
end
