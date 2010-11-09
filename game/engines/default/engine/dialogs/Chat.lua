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
local VariableList = require "engine.ui.VariableList"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(chat, id)
	self.cur_id = id
	self.chat = chat
	self.npc = chat.npc
	self.player = chat.player
	Dialog.init(self, self.npc.name, 500, 400)

	self:generateList()

	self.c_desc = Textzone.new{width=self.iw - 10, height=1, auto_height=true, no_color_bleed=true, text=self.text.."\n"}

	self:generateList()

	self.c_list = VariableList.new{width=self.iw - 10, list=self.list, fct=function(item) self:use(item) end, select=function(item) self:select(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_desc},
		{left=0, bottom=0, ui=self.c_list},
		{left=5, top=self.c_desc.h - 10, ui=Separator.new{dir="vertical", size=self.iw - 10}},
	}
	self:setFocus(self.c_list)
	self:setupUI(false, true)

	self.key:addCommands{
		__TEXTINPUT = function(c)
			if self.list and self.list.chars[c] then
				self:use(self.list[self.list.chars[c]])
			end
		end,
	}
end

function _M:select(item)
	local a = self.chat:get(self.cur_id).answers[item.answer]
	if not a then return end

	if a.on_select then
		a.on_select(self.npc, self.player, self)
	end
end

function _M:use(item, a)
	a = a or self.chat:get(self.cur_id).answers[item.answer]
	if not a then return end

	print("[CHAT] selected", a[1], a.action, a.jump)
	if a.switch_npc then self.chat:switchNPC(a.switch_npc) end
	if a.action then
		local id = a.action(self.npc, self.player, self)
		if id then
			self.cur_id = id
			self:regen()
			return
		end
	end
	if a.jump and not self.killed then
		self.cur_id = a.jump
		self:regen()
	else
		game:unregisterDialog(self)
		return
	end
end

function _M:regen()
	local d = new(self.chat, self.cur_id)
	d.__showup = false
	game:replaceDialog(self, d)
	self.next_dialog = d
end
function _M:resolveAuto()
--[[
	if not self.chat:get(self.cur_id).auto then return end
	for i, a in ipairs(self.chat:get(self.cur_id).answers) do
		if not a.cond or a.cond(self.npc, self.player) then
			if not self:use(nil, a) then return
			else return self:resolveAuto()
			end
		end
	end
]]
end

function _M:generateList()
	self:resolveAuto()

	-- Makes up the list
	local list = { chars={} }
	local nb = 1
	for i, a in ipairs(self.chat:get(self.cur_id).answers) do
		if not a.cond or a.cond(self.npc, self.player) then
			list[#list+1] = { name=string.char(string.byte('a')+nb-1)..") "..a[1], answer=i, color=a.color}
			list.chars[string.char(string.byte('a')+nb-1)] = #list
			nb = nb + 1
		end
	end
	self.list = list

	self.text = self.chat:replace(self.chat:get(self.cur_id).text)

	return true
end
