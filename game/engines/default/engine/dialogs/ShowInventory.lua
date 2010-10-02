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

function _M:init(title, inven, filter, action, actor)
	self.inven = inven
	self.filter = filter
	self.action = action
	self.actor = actor
	Dialog.init(self, title or "Inventory", game.w * 0.8, game.h * 0.8)

	self.c_desc = Textzone.new{width=math.floor(self.iw / 2 - 10), height=self.ih, no_color_bleed=true, text=""}

	self:generateList()

	self.c_list = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, scrollbar=true, columns={
		{name="", width=4, display_prop="char"},
		{name="Inventory", width=68, display_prop="name"},
		{name="Category", width=20, display_prop="cat"},
		{name="Enc.", width=8, display_prop="encumberance"},
	}, list=self.list, fct=function(item) self:use(item) end, select=function(item, sel) self:select(item) end}

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
		ACCEPT = function()
			self:use(self.c_list.list[self.c_list.sel])
		end,
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:select(item)
	if item then
		self.uis[2].ui = item.zone
	end
end
function _M:use(item)
	if item and item.object then
		self.action(item.object, item.item)
	end
	game:unregisterDialog(self)
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	list.chars = {}
	local i = 0
	for item, o in ipairs(self.inven) do
		if not self.filter or self.filter(o) then
			local char = string.char(string.byte('a') + i)
			list.chars[char] = i
			local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=o:getDesc()}
			list[#list+1] = { char=char, zone=zone, name=o:getDisplayString()..o:getName(), color=o:getDisplayColor(), object=o, item=item, cat=o.subtype, encumberance=o.encumber }
			i = i + 1
		end
	end
	self.list = list
end
