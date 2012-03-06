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
local Module = require "engine.Module"
local Dialog = require "engine.ui.Dialog"
local Button = require "engine.ui.Button"
local Textbox = require "engine.ui.Textbox"
local Dropdown = require "engine.ui.Dropdown"
local Textzone = require "engine.ui.Textzone"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(chat, on_end)
	self.on_end = on_end
	self.chat = chat
	self.min = 2
	self.max = 300
	self.absolute = absolute

	Dialog.init(self, self:getTitle(), 320, 110)

	local c_box = Textbox.new{title="Say: ", text="", chars=60, max_len=max,
		fct=function(text) self:okclick() end,
		on_change = function(text) self:checkTarget(text) end,
	}
	self.c_box = c_box
	local ok = Button.new{text="Accept", fct=function() self:okclick() end}
	local cancel = Button.new{text="Cancel", fct=function() self:cancelclick() end}

	local list = self:getTargets()
	self.c_list_text = Textzone.new{auto_width=true, auto_height=true, text="Target: "}
	self.c_list = Dropdown.new{width=250, fct=function(item) if not item then return end self:checkTarget(item.id..":") self:setFocus(c_box) end, list=list, nb_items=math.min(#list, 10), scrollbar=true}

	self:loadUI{
		{left=0, top=0, ui=self.c_box},

		{left=self.c_box.w - self.c_list.w - self.c_list_text.w - 6, top=self.c_box.h + 10, ui=self.c_list_text},
		{left=self.c_box.w - self.c_list.w, top=self.c_box.h + 10, ui=self.c_list},

		{left=0, bottom=0, ui=ok},
		{left=self.c_box.w - ok.w, bottom=0, ui=cancel},
	}
	self:setFocus(c_box)
	self:setupUI(true, true)

	self:getTitle()

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
	self.key:addCommand("_ESCAPE", function() game:unregisterDialog(self) end)
--	self.key:addCommand("_TAB", function()
--		self:checkTarget(self.c_box.text)
--	end)
end

function _M:getTargets()
	local list = {}
	for name, _ in pairs(self.chat.channels) do list[#list+1] = {name="Channel: "..name, id=name} end
	if self.chat.channels[self.chat.cur_channel] then
		for login, data in pairs(self.chat.channels[self.chat.cur_channel].users) do list[#list+1] = {name="User: "..data.name, id=data.name} end
	end
	return list
end

function _M:getTitle()
	local type, name = self.chat:getCurrentTarget()
	if self.c_list then for i = 1, #self.c_list.c_list.list do
		if self.c_list.c_list.list[i].id == name then self.c_list.c_list.sel = i break end
	end end
	if type == "channel" then
		return "Talk on channel: "..name
	elseif type == "whisper" then
		return "Whisper to: "..name
	end
	return "????"
end

function _M:checkTarget(text)
	if text:sub(text:len()) == ":" then
		local name = text:sub(1, text:len() - 1)
		local channel = self.chat:findChannel(name)
		local uname = self.chat:findUser(name)
		if uname then
			self.chat:setCurrentTarget(false, uname or name)
			self:updateTitle(self:getTitle())
			self.c_box:setText("")
		elseif channel then
			self.chat:setCurrentTarget(true, channel)
			self:updateTitle(self:getTitle())
			self.c_box:setText("")
		end
	end
end

function _M:okclick()
	local text = self.c_box.text
	if text:len() >= self.min and text:len() <= self.max then
		game:unregisterDialog(self)

		local type, name = self.chat:getCurrentTarget()
		if type == "channel" then
			self.chat:talk(text)
		elseif type == "whisper" then
			self.chat:whisper(name, text)
		end

		if self.on_end then self.on_end() end
	end
end

function _M:cancelclick()
	self.key:triggerVirtual("EXIT")
end
