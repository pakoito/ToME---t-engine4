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

function _M:init(actor)
	self.actor = actor
	actor.hotkey = actor.hotkey or {}
	Dialog.init(self, "Use Talents: "..actor.name, game.w * 0.7, game.h * 0.7)

	self.c_tut = Textzone.new{width=math.floor(self.iw / 2 - 10), height=1, auto_height=true, no_color_bleed=true, text=[[
You can bind a talent to a hotkey be pressing the corresponding hotkey while selecting a talent.
Check out the keybinding screen in the game menu to bind hotkeys to a key (default is 1-0 plus control or shift).
]]}
	self.c_desc = Textzone.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.c_tut.h - 20, no_color_bleed=true, text=""}

	self:generateList()

	self.c_list = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, sortable=true, scrollbar=true, columns={
		{name="", width={20,"fixed"}, display_prop="char", sort="id"},
		{name="Talent", width=80, display_prop="name", sort="name"},
		{name="Status", width=20, display_prop="status", sort="status"},
	}, list=self.list, fct=function(item) self:use(item) end, select=function(item, sel) self:select(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{right=0, top=self.c_tut.h + 20, ui=self.c_desc},
		{right=0, top=0, ui=self.c_tut},
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
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:defineHotkey(id)
	if not self.actor.hotkey then return end
	local item = self.list[self.sel]
	if not item or not item.talent then return end

	self.actor.hotkey[id] = {"talent", item.talent}
	self:simplePopup("Hotkey "..id.." assigned", self.actor:getTalentFromId(item.talent).name:capitalize().." assigned to hotkey "..id)
	self.actor.changed = true
end

function _M:select(item)
	if item and self.uis[2] then
		self.uis[2].ui = item.zone
	end
end

function _M:use(item)
	game:unregisterDialog(self)
	self.actor:useTalent(item.talent)
end

function _M:makeKey(letter)
	if letter >= 26 then
		return string.char(string.byte('A') + letter - 26)
	else
		return string.char(string.byte('a') + letter)
	end
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local keybind = {}
	local letter = 0
	for i, tt in ipairs(self.actor.talents_types_def) do
		local cat = tt.type:gsub("/.*", "")
		local where = #list
		local added = false

		-- Find all talents of this school
		for j, t in ipairs(tt.talents) do
			if self.actor:knowTalent(t.id) and t.mode ~= "passive" then
				local typename = "talent"
				local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=self.actor:getTalentFullDescription(t)}
				local status = "#LIGHT_GREEN#Active#WHITE#"
				if t.mode == "sustained" then status = self.actor:isTalentActive(t.id) and "#YELLOW#Sustaining#WHITE#" or "#LIGHT_GREEN#Sustain#WHITE#" end
				list[#list+1] = { zone=zone, char=self:makeKey(letter), name=t.name.." ("..typename..")", status=status, talent=t.id }
				keybind[self:makeKey(letter)] = #list + 1
				if not self.sel then self.sel = #list + 1 end
				letter = letter + 1
				added = true
			end
		end

		if added then
			local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=tt.description}
			table.insert(list, where+1, { zone=zone, char="", name="#{bold}#"..cat:capitalize().." / "..tt.name:capitalize().."#{normal}#", type=tt.type, color={0x80, 0x80, 0x80}, status="" })
		end
	end
	for i = 1, #list do list[i].id = i end
	self.list = list
	self.keybind = keybind
end
