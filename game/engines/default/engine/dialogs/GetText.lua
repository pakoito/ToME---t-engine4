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

module(..., package.seeall, class.inherit(Dialog))

function _M:init(title, text, min, max, action, cancel, absolute)
	self.action = action
	self.cancel = cancel
	self.min = min or 2
	self.max = max or 25
	self.absolute = absolute

	Dialog.init(self, title, 320, 110)

	local c_box = Textbox.new{title=text..": ", text="", chars=30, max_len=max, fct=function(text) self:okclick() end}
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
		EXIT = function() if self.cancel then self.cancel() end game:unregisterDialog(self) end,
	}
end

function _M:okclick()
	self.name = self.c_box.text
	if self.name:len() >= self.min and self.name:len() <= self.max then
		game:unregisterDialog(self)
		self.action(self.name)
	else
		Dialog:simplePopup("Error", ("Must be between %i and %i characters."):format(self.min, self.max))
	end
end

function _M:cancelclick()
	self.key:triggerVirtual("EXIT")
end
