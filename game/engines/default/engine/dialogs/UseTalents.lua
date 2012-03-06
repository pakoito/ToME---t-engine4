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

function _M:init(actor)
	self.actor = actor
	actor.hotkey = actor.hotkey or {}
	Dialog.init(self, "Use Talents: "..actor.name, game.w * 0.7, game.h * 0.7)

	self.c_tut = Textzone.new{width=math.floor(self.iw / 2 - 10), height=1, auto_height=true, no_color_bleed=true, text=[[
You can bind a talent to a hotkey be pressing the corresponding hotkey while selecting a talent.
Check out the keybinding screen in the game menu to bind hotkeys to a key (default is 1-0 plus control or shift).
]]}
	self.c_desc = TextzoneList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.c_tut.h - 20, scrollbar=true, no_color_bleed=true}

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
				self:use(self.list.chars[c])
			end
		end,
	}
	if engine.interface and engine.interface.PlayerHotkeys then engine.interface.PlayerHotkeys:bindAllHotkeys(self.key, function(i) self:defineHotkey(i) end) end
	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:on_register()
	game:onTickEnd(function() self.key:unicodeInput(true) end)
end

function _M:defineHotkey(id)
	if not self.actor.hotkey then return end
	local item = self.list[self.c_list.sel]
	if not item or not item.talent then return end

	self.actor.hotkey[id] = {"talent", item.talent}
	self:simplePopup("Hotkey "..id.." assigned", self.actor:getTalentFromId(item.talent).name:capitalize().." assigned to hotkey "..id)
	self.actor.changed = true
end

function _M:select(item)
	if item then
		self.c_desc:switchItem(item, item.desc)
	end
end

function _M:use(item)
	if not item or not item.talent then return end

	game:unregisterDialog(self)
	self.actor:useTalent(item.talent)
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	list.chars = {}
	local letter = 1
	for i, tt in ipairs(self.actor.talents_types_def) do
		local cat = tt.type:gsub("/.*", "")
		local where = #list
		local added = false

		-- Find all talents of this school
		for j, t in ipairs(tt.talents) do
			if self.actor:knowTalent(t.id) and t.mode ~= "passive" then
				local typename = "talent"
				local status = tstring{{"color", "LIGHT_GREEN"}, "Active"}
				if self.actor:isTalentCoolingDown(t) then status = tstring{{"color", "LIGHT_RED"}, self.actor:isTalentCoolingDown(t).." turns"}
				elseif t.mode == "sustained" then status = self.actor:isTalentActive(t.id) and tstring{{"color", "YELLOW"}, "Sustaining"} or tstring{{"color", "LIGHT_GREEN"}, "Sustain"} end
				list[#list+1] = { char=self:makeKeyChar(letter), name=t.name.." ("..typename..")", status=status, talent=t.id, desc=self.actor:getTalentFullDescription(t) }
				list.chars[self:makeKeyChar(letter)] = list[#list]
				if not self.sel then self.sel = #list + 1 end
				letter = letter + 1
				added = true
			end
		end

		if added then
			table.insert(list, where+1, { char="", name=tstring{{"font","bold"}, cat:capitalize().." / "..tt.name:capitalize(), {"font","normal"}}, type=tt.type, color={0x80, 0x80, 0x80}, status="", desc=tt.description })
		end
	end
	for i = 1, #list do list[i].id = i end
	self.list = list
end
