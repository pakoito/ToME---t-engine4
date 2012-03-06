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

function _M:init(title, inven, filter, action, actor)
	self.inven = inven
	self.filter = filter
	self.action = action
	self.actor = actor
	Dialog.init(self, title or "Inventory", math.max(800, game.w * 0.8), math.max(600, game.h * 0.8))

	self.c_desc = TextzoneList.new{width=math.floor(self.iw / 2 - 10), height=self.ih, no_color_bleed=true}

	self.c_list = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, sortable=true, scrollbar=true, columns={
		{name="", width={20,"fixed"}, display_prop="char", sort="id"},
		{name="", width={24,"fixed"}, display_prop="object", sort="sortname", direct_draw=function(item, x, y) item.object:toScreen(nil, x+4, y, 16, 16) end},
		{name="Inventory", width=72, display_prop="name", sort="sortname"},
		{name="Category", width=20, display_prop="cat", sort="cat"},
		{name="Enc.", width=8, display_prop="encumberance", sort="encumberance"},
	}, list={}, fct=function(item) self:use(item) end, select=function(item, sel) self:select(item) end}

	self:generateList()

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{right=0, top=0, ui=self.c_desc},
		{hcenter=0, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self.key:addCommands{
		__TEXTINPUT = function(c)
			if self.list and self.list.chars[c] then
				self:use(self.list[self.list.chars[c]])
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

function _M:select(item)
	if item then
		self.c_desc:switchItem(item, item.desc)
	end
end
function _M:use(item)
	local dont_end = false
	if item and item.object then
		dont_end = self.action(item.object, item.item)
	end
	self:generateList()
	self:select(self.c_list.list[self.c_list.sel])
	if not dont_end then game:unregisterDialog(self) end
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	list.chars = {}
	local i = 1
	for item, o in ipairs(self.inven or {}) do
		if not self.filter or self.filter(o) then
			local char = self:makeKeyChar(i)

			local enc = 0
			o:forAllStack(function(o) enc=enc+o.encumber end)

			list[#list+1] = { id=i, char=char, name=o:getName(), sortname=o:getName():toString():removeColorCodes(), color=o:getDisplayColor(), object=o, item=item, cat=o.subtype, encumberance=enc, desc=o:getDesc() }
			list.chars[char] = #list
			i = i + 1
		end
	end
	self.list = list
	self.c_list:setList(list)
end
