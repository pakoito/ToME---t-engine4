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

module(..., package.seeall, class.inherit(Dialog))

function _M:init(title, actor, filter, action)
	self.action = action
	self.filter = filter
	self.actor = actor

	Dialog.init(self, title or "Inventory", game.w * 0.8, game.h * 0.8)

	self:generateList()

	self.c_inven = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.max_h - 10, sortable=true, scrollbar=true, columns={
		{name="", width=7, display_prop="id", sort="id"},
		{name="", width=4, display_prop="char", sort="char"},
		{name="Inventory", width=61, display_prop="name", sort="name"},
		{name="Category", width=20, display_prop="cat", sort="cat"},
		{name="Enc.", width=8, display_prop="encumberance", sort="encumberance"},
	}, list=self.inven_list, fct=function(item, sel) self:use(item) end}

	self.c_equip = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.max_h - 10, scrollbar=true, columns={
		{name="", width=4, display_prop="char", sort="char"},
		{name="Equipment", width=68, display_prop="name"},
		{name="Category", width=20, display_prop="cat"},
		{name="Enc.", width=8, display_prop="encumberance"},
	}, list=self.equip_list, fct=function(item) self:use(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_equip},
		{right=0, top=0, ui=self.c_inven},
	}


	self.key:addCommands{
		__TEXTINPUT = function(c)
			if self.list.chars[c] then
				self.sel = self.list.chars[c]
				self:use()
			end
		end,
	}
	self.key:addBinds{
		HOTKEY_1 = function() self:defineHotkey(1) end,
		HOTKEY_2 = function() self:defineHotkey(2) end,
		HOTKEY_3 = function() self:defineHotkey(3) end,
		HOTKEY_4 = function() self:defineHotkey(4) end,
		HOTKEY_5 = function() self:defineHotkey(5) end,
		HOTKEY_6 = function() self:defineHotkey(6) end,
		HOTKEY_7 = function() self:defineHotkey(7) end,
		HOTKEY_8 = function() self:defineHotkey(8) end,
		HOTKEY_9 = function() self:defineHotkey(9) end,
		HOTKEY_10 = function() self:defineHotkey(10) end,
		HOTKEY_11 = function() self:defineHotkey(11) end,
		HOTKEY_12 = function() self:defineHotkey(12) end,
		HOTKEY_SECOND_1 = function() self:defineHotkey(13) end,
		HOTKEY_SECOND_2 = function() self:defineHotkey(14) end,
		HOTKEY_SECOND_3 = function() self:defineHotkey(15) end,
		HOTKEY_SECOND_4 = function() self:defineHotkey(16) end,
		HOTKEY_SECOND_5 = function() self:defineHotkey(17) end,
		HOTKEY_SECOND_6 = function() self:defineHotkey(18) end,
		HOTKEY_SECOND_7 = function() self:defineHotkey(19) end,
		HOTKEY_SECOND_8 = function() self:defineHotkey(20) end,
		HOTKEY_SECOND_9 = function() self:defineHotkey(21) end,
		HOTKEY_SECOND_10 = function() self:defineHotkey(22) end,
		HOTKEY_SECOND_11 = function() self:defineHotkey(23) end,
		HOTKEY_SECOND_12 = function() self:defineHotkey(24) end,
		HOTKEY_THIRD_1 = function() self:defineHotkey(25) end,
		HOTKEY_THIRD_2 = function() self:defineHotkey(26) end,
		HOTKEY_THIRD_3 = function() self:defineHotkey(27) end,
		HOTKEY_THIRD_4 = function() self:defineHotkey(28) end,
		HOTKEY_THIRD_5 = function() self:defineHotkey(29) end,
		HOTKEY_THIRD_6 = function() self:defineHotkey(30) end,
		HOTKEY_THIRD_7 = function() self:defineHotkey(31) end,
		HOTKEY_THIRD_8 = function() self:defineHotkey(31) end,
		HOTKEY_THIRD_9 = function() self:defineHotkey(33) end,
		HOTKEY_THIRD_10 = function() self:defineHotkey(34) end,
		HOTKEY_THIRD_11 = function() self:defineHotkey(35) end,
		HOTKEY_THIRD_12 = function() self:defineHotkey(36) end,
		ACCEPT = function()
			if self.focus_ui and self.focus_ui.ui == self.c_inven then self:use(self.c_inven.list[self.c_inven.sel])
			elseif self.focus_ui and self.focus_ui.ui == self.c_equip then self:use(self.c_equip.list[self.c_equip.sel])
			end
		end,
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:defineHotkey(id)
	if not self.actor or not self.actor.hotkey then return end

	local item = nil
	if self.focus_ui and self.focus_ui.ui == self.c_inven then item = self.c_inven.list[self.c_inven.sel]
	elseif self.focus_ui and self.focus_ui.ui == self.c_equip then item = self.c_equip.list[self.c_equip.sel]
	end
	if not item or not item.object then return end

	self.actor.hotkey[id] = {"inventory", item.object:getName{no_count=true}}
	self:simplePopup("Hotkey "..id.." assigned", item.object:getName{no_count=true}:capitalize().." assigned to hotkey "..id)
	self.actor.changed = true
end

function _M:use(item)
	if item then
		if self.action(item.object, item.inven, item.item) then
			game:unregisterDialog(self)
		end
	end
end

function _M:generateList()
	-- Makes up the list
	self.equip_list = {}
	local list = self.equip_list
	local chars = {}
	local i = 0
	self.max_h = 0
	for inven_id =  1, #self.actor.inven_def do
		if self.actor.inven[inven_id] and self.actor.inven_def[inven_id].is_worn then
			list[#list+1] = { id=#list+1, char="", name=self.actor.inven_def[inven_id].name, color={0x90, 0x90, 0x90}, inven=inven_id, cat="", encumberance="" }
			self.max_h = math.max(self.max_h, #self.actor.inven_def[inven_id].description:splitLines(self.iw - 10, self.font))

			for item, o in ipairs(self.actor.inven[inven_id]) do
				if not self.filter or self.filter(o) then
					local char = string.char(string.byte('a') + i)
					list[#list+1] = { id=#list+1, char=char, name=o:getDisplayString()..o:getName(), color=o:getDisplayColor(), object=o, inven=inven_id, item=item, cat=o.type.."/"..o.subtype, encumberance=o.encumber }
					self.max_h = math.max(self.max_h, #o:getDesc():splitLines(self.iw - 10, self.font))
					chars[char] = #list
					i = i + 1
				end
			end
		end
	end
	list.chars = chars
	self.equip_list = list

	-- Makes up the list
	self.inven_list = {}
	local list = self.inven_list
	local chars = {}
	local i = 0
	for item, o in ipairs(self.actor:getInven("INVEN")) do
		if not self.filter or self.filter(o) then
			local char = string.char(string.byte('a') + i)
			list[#list+1] = { id=#list+1, char=char, name=o:getDisplayString()..o:getName(), color=o:getDisplayColor(), object=o, inven=self.actor.INVEN_INVEN, item=item, cat=o.type.."/"..o.subtype, encumberance=o.encumber }
			self.max_h = math.max(self.max_h, #o:getDesc():splitLines(self.iw - 10, self.font))
			chars[char] = #list
			i = i + 1
		end
	end
	list.chars = chars
end

function _M:on_recover_focus()
	self:generateList()
end

function _M:drawDialog(s)
	if self.list[self.sel] and not self.list[self.sel].item then
		lines = self.actor.inven_def[self.list[self.sel].inven].description:splitLines(self.iw / 2 - 10, self.font)
	elseif self.list[self.sel] and self.list[self.sel] and self.list[self.sel].object then
		lines = self.list[self.sel].object:getDesc():splitLines(self.iw - 10, self.font)
	else
		lines = {}
	end

	local sh = self.ih - 4 - self.max_h * self.font:lineSkip()
	h = sh
	self:drawWBorder(s, 3, sh, self.iw - 6)
	for i = 1, #lines do
		s:drawColorStringBlended(self.font, lines[i], 5, 2 + h)
		h = h + self.font:lineSkip()
	end

	self:drawSelectionList(s, 2, 5, self.font_h, self.equip_list, self.list == self.equip_list and self.sel or -1, "name", self.scroll, self.max, nil, nil, nil, self.iw / 2 - 5, true)
	self:drawHBorder(s, self.iw / 2, 2, sh - 4)
	self:drawSelectionList(s, self.iw / 2 + 5, 5, self.font_h, self.inven_list, self.list == self.inven_list and self.sel or -1, "name", self.scroll, self.max, nil, nil, nil, self.iw / 2 - 5, true)
	self.changed = false
end
