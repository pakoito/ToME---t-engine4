-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
local TreeList = require "engine.ui.TreeList"
local ListColumns = require "engine.ui.ListColumns"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
	self.actor = actor
	actor.hotkey = actor.hotkey or {}
	Dialog.init(self, "Use Talents: "..actor.name, game.w * 0.8, game.h * 0.8)

	self.c_tut = Textzone.new{width=math.floor(self.iw / 2 - 10), height=1, auto_height=true, no_color_bleed=true, text=[[
You can bind a talent to a hotkey by pressing the corresponding hotkey while selecting a talent or by right-clicking on the talent.
Check out the keybinding screen in the game menu to bind hotkeys to a key (default is 1-0 plus control or shift).
]]}
	self.c_desc = TextzoneList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.c_tut.h - 20, scrollbar=true, no_color_bleed=true}

	self:generateList()

	local cols = {
		{name="", width={40,"fixed"}, display_prop="char"},
		{name="Talent", width=80, display_prop="name"},
		{name="Status", width=20, display_prop="status"},
		{name="Hotkey", width={75,"fixed"}, display_prop="hotkey"},
		{name="Left Mouse", width={60,"fixed"}, display_prop=function(item)
			if item.talent and item.talent == self.actor.auto_shoot_talent then return "LeftClick" else return "" end
		end},
	}
	self.c_list = TreeList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, all_clicks=true, scrollbar=true, columns=cols, tree=self.list, fct=function(item, sel, button) self:use(item, button) end, select=function(item, sel) self:select(item) end}
	self.c_list.cur_col = 2

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
		HOTKEY_THIRD_8 = function() self:defineHotkey(32) end,
		HOTKEY_THIRD_9 = function() self:defineHotkey(33) end,
		HOTKEY_THIRD_10 = function() self:defineHotkey(34) end,
		HOTKEY_THIRD_11 = function() self:defineHotkey(35) end,
		HOTKEY_THIRD_12 = function() self:defineHotkey(36) end,
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:defineHotkey(id)
	if not self.actor.hotkey then return end
	local item = self.cur_item
	if not item or not item.talent then return end

	for i = 1, 36 do
		if self.actor.hotkey[i] and self.actor.hotkey[i][1] == "talent" and self.actor.hotkey[i][2] == item.talent then self.actor.hotkey[i] = nil end
	end

	self.actor.hotkey[id] = {"talent", item.talent}
	self:simplePopup("Hotkey "..id.." assigned", self.actor:getTalentFromId(item.talent).name:capitalize().." assigned to hotkey "..id)
	self.c_list:drawTree()
	self.actor.changed = true
end

function _M:select(item)
	if item then
		self.c_desc:switchItem(item, item.desc)
		self.cur_item = item
	end
end

function _M:use(item, button)
	if not item or not item.talent then return end

	if button == "right" then
		local list = {
			{name="Unbind", what="unbind"},
			{name="Bind to left mouse click (on a target)", what="left"},
			{name="Bind to middle mouse click (on a target)", what="middle"},
		}
		for i = 1, 36 do list[#list+1] = {name="Hotkey "..i, what=i} end
		Dialog:listPopup("Bind talent: "..item.name, "How do you want to bind this talent?", list, 400, 500, function(b)
			if not b then return end
			if type(b.what) == "number" then
				for i = 1, 36 do
					if self.actor.hotkey[i] and self.actor.hotkey[i][1] == "talent" and self.actor.hotkey[i][2] == item.talent then self.actor.hotkey[i] = nil end
				end
				self.actor.hotkey[b.what] = {"talent", item.talent}
				self:simplePopup("Hotkey "..b.what.." assigned", self.actor:getTalentFromId(item.talent).name:capitalize().." assigned to hotkey "..b.what)
			elseif b.what == "middle" then
				self.actor.auto_shoot_midclick_talent = item.talent
				self:simplePopup("Middle mouse click assigned", self.actor:getTalentFromId(item.talent).name:capitalize().." assigned to middle mouse click on an hostile target.")
			elseif b.what == "left" then
				self.actor.auto_shoot_talent = item.talent
				self:simplePopup("Left mouse click assigned", self.actor:getTalentFromId(item.talent).name:capitalize().." assigned to left mouse click on an hostile target.")
			elseif b.what == "unbind" then
				if self.actor.auto_shoot_talent == item.talent then self.actor.auto_shoot_talent = nil end
				if self.actor.auto_shoot_midclick_talent == item.talent then self.actor.auto_shoot_midclick_talent = nil end
				for i = 1, 36 do
					if self.actor.hotkey[i] and self.actor.hotkey[i][1] == "talent" and self.actor.hotkey[i][2] == item.talent then self.actor.hotkey[i] = nil end
				end
			end
			self.c_list:drawTree()
			self.actor.changed = true
		end)
		return
	end

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
		local nodes = {}

		-- Find all talents of this school
		for j, t in ipairs(tt.talents) do
			if self.actor:knowTalent(t.id) and t.mode ~= "passive" then
				local typename = "talent"
				local status = tstring{{"color", "LIGHT_GREEN"}, "Active"}
				if self.actor:isTalentCoolingDown(t) then status = tstring{{"color", "LIGHT_RED"}, self.actor:isTalentCoolingDown(t).." turns"}
				elseif t.mode == "sustained" then status = self.actor:isTalentActive(t.id) and tstring{{"color", "YELLOW"}, "Sustaining"} or tstring{{"color", "LIGHT_GREEN"}, "Sustain"} end
				nodes[#nodes+1] = {
					char=self:makeKeyChar(letter),
					name=t.name.." ("..typename..")",
					status=status,
					talent=t.id,
					desc=self.actor:getTalentFullDescription(t),
					color=function() return {0xFF, 0xFF, 0xFF} end,
					hotkey=function(item)
						for i = 1, 36 do if self.actor.hotkey[i] and self.actor.hotkey[i][1] == "talent" and self.actor.hotkey[i][2] == item.talent then
							return "H.Key "..i..""
						end end
						return ""
					end,
				}
				list.chars[self:makeKeyChar(letter)] = nodes[#nodes]
				added = true
				letter = letter + 1
			end
		end

		if added then
			table.insert(list, where+1, {
				char="",
				name=tstring{{"font","bold"}, cat:capitalize().." / "..tt.name:capitalize(), {"font","normal"}},
				type=tt.type,
				color=function() return {0x80, 0x80, 0x80} end,
				status="",
				desc=tt.description,
				nodes=nodes,
				hotkey="",
				shown=true,
			})
		end

	end
	for i = 1, #list do list[i].id = i end
	self.list = list
end
