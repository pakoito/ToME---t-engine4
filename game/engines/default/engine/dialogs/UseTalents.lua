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
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actor)
	self.actor = actor
	actor.hotkey = actor.hotkey or {}
	engine.Dialog.init(self, "Use Talents: "..actor.name, game.w / 2, game.h / 2)

	self:generateList()

	self.scroll = 1
	self.max = math.floor((self.ih - 5) / self.font_h) - 1

	self:keyCommands({
		__TEXTINPUT = function(c)
			if c:find("^[a-zA-Z]$") then
				local sel = self.keybind[c]
				if sel then
					self.sel = sel
					self:use()
				end
			end
		end,
	},{
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

		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		ACCEPT = function() self:use() end,
		EXIT = function() game:unregisterDialog(self) end,
	})
	self:mouseZones{
		{ x=0, y=0, w=game.w, h=game.h, mode={button=true}, norestrict=true, fct=function(button) if button ~= "none" then game:unregisterDialog(self) end end},
		{ x=2, y=5, w=350, h=self.font_h*self.max, fct=function(button, x, y, xrel, yrel, tx, ty)
			self.changed = true
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
			if button == "left" then self:use()
			elseif button == "right" then
			end
		end },
	}
end

function _M:defineHotkey(id)
	if not self.actor.hotkey then return end

	self.actor.hotkey[id] = {"talent", self.list[self.sel].talent}
	self:simplePopup("Hotkey "..id.." assigned", self.actor:getTalentFromId(self.list[self.sel].talent).name:capitalize().." assigned to hotkey "..id)
	self.actor.changed = true
end

function _M:use()
	game:unregisterDialog(self)
	self.actor:useTalent(self.list[self.sel].talent)
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
				if t.type[1]:find("^spell/") then typename = "spell" end
				list[#list+1] = { name=self:makeKey(letter)..")    "..t.name.." ("..typename..")"..(self.actor:isTalentActive(t.id) and " <sustaining>" or ""), talent=t.id }
				keybind[self:makeKey(letter)] = #list + 1
				if not self.sel then self.sel = #list + 1 end
				letter = letter + 1
				added = true
			end
		end

		if added then
			table.insert(list, where+1, { name=cat:capitalize().." / "..tt.name:capitalize(), type=tt.type, color={0x80, 0x80, 0x80} })
		end
	end
	self.list = list
	self.keybind = keybind
end

function _M:drawDialog(s)
	-- Description part
	self:drawHBorder(s, self.iw / 2, 2, self.ih - 4)

	local help
	if not self.actor.hotkey then
		help = [[Keyboard: #00FF00#up key/down key#FFFFFF# to select a stat; #00FF00#enter#FFFFFF# to use.
Mouse: #00FF00#Left click#FFFFFF# to use.
]]
	else
		help = [[Keyboard: #00FF00#up key/down key#FFFFFF# to select a stat; #00FF00#enter#FFFFFF# to use.
#00FF00#1-0#FFFFFF# to assign a hotkey.
Mouse: #00FF00#Left click#FFFFFF# to use.
]]
	end
	local talentshelp = help:splitLines(self.iw / 2 - 10, self.font)

	local lines = {}
	if self.list[self.sel].type then
		lines = self.actor:getTalentTypeFrom(self.list[self.sel].type).description:splitLines(self.iw / 2 - 10, self.font)
	else
		local t = self.actor:getTalentFromId(self.list[self.sel].talent)
		lines = self.actor:getTalentFullDescription(t):splitLines(self.iw / 2 - 10, self.font)
	end

	local h = 2
	for i = 1, #talentshelp do
		s:drawColorStringBlended(self.font, talentshelp[i], self.iw / 2 + 5, h)
		h = h + self.font:lineSkip()
	end

	h = h + self.font:lineSkip()
	self:drawWBorder(s, self.iw / 2 + self.iw / 6, h - 0.5 * self.font:lineSkip(), self.iw / 6)
	for i = 1, #lines do
		s:drawColorStringBlended(self.font, lines[i], self.iw / 2 + 5, 2 + h)
		h = h + self.font:lineSkip()
	end

	-- Talents
	self:drawSelectionList(s, 2, 5, self.font_h, self.list, self.sel, "name", self.scroll, self.max, nil, nil, nil, self.iw / 2 - 5)
	self.changed = false
end
