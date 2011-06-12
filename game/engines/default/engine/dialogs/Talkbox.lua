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
local Module = require "engine.Module"
local Dialog = require "engine.ui.Dialog"
local Button = require "engine.ui.Button"
local Textbox = require "engine.ui.Textbox"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(chat)
	self.chat = chat
	self.min = 2
	self.max = 300
	self.absolute = absolute

	Dialog.init(self, self:getTitle(), 320, 110)

	local c_box = Textbox.new{title="Say: ", text="", chars=30, max_len=max,
		fct=function(text) self:okclick() end,
		on_change = function(text) self:checkTarget(text) end,
	}
	self.c_box = c_box
	local ok = require("engine.ui.Button").new{text="Accept", fct=function() self:okclick() end}
	local cancel = require("engine.ui.Button").new{text="Cancel", fct=function() self:cancelclick() end}

	self:loadUI{
		{left=0, top=0, padding_h=10, ui=c_box},
		{left=0, bottom=0, ui=ok},
		{right=0, bottom=0, ui=cancel},
	}
	self:setFocus(c_box)
	self:setupUI(true, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
	self.key:addCommand("_ESCAPE", function() game:unregisterDialog(self) end)
--	self.key:addCommand("_TAB", function()
--		self:checkTarget(self.c_box.text)
--	end)
end

function _M:getTitle()
	local type, name = self.chat:getCurrentTarget()
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
	end
end

function _M:cancelclick()
	self.key:triggerVirtual("EXIT")
end
