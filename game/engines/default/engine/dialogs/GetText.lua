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
local Module = require "engine.Module"
local Dialog = require "engine.Dialog"
local Button = require "engine.Button"
local TextBox = require "engine.TextBox"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(title, text, min, max, action)
	engine.Dialog.init(self, title, 320, 110)
	self.text = text
	self.min = min or 2
	self.max = max or 25
	self.action = action
	self.name = ""
	self:keyCommands({
		_DELETE = function()
			if self.controls[self.state] and self.controls[self.state].delete then
				self.controls[self.state]:delete()
			end
			self.changed = true
		end,
		_TAB = function()
			self.state = self:changeFocus(true)
			self.changed = true
		end,
		_DOWN = function()
			self.state = self:changeFocus(true)
			self.changed = true
		end,
		_UP = function()
			self.state = self:changeFocus(false)
			self.changed = true
		end,
		_RIGHT = function()
			if self.state ~= "" and self.controls[self.state] and self.controls[self.state].moveRight then
				self.controls[self.state]:moveRight(1)
			else
				self.state = self:changeFocus(true)
			end
			self.changed = true
		end,
		_LEFT = function()
			if self.state ~= "" and self.controls[self.state] and self.controls[self.state].moveLeft then
				self.controls[self.state]:moveLeft(1)
			else
				self.state = self:changeFocus(false)
			end
			self.changed = true
		end,
		_BACKSPACE = function()
			if self.state ~= "" and self.controls[self.state] and self.controls[self.state].type=="TextBox" then
				self.controls[self.state]:backSpace()
			end
			self.changed = true
		end,
		__TEXTINPUT = function(c)
			if self.state ~= "" and self.controls[self.state] and self.controls[self.state].type=="TextBox" then
				self.controls[self.state]:textInput(c)
			end
			self.changed = true
		end,
		_RETURN = function()
			if self.state ~= "" and self.controls[self.state] and self.controls[self.state].type=="Button" then
				self.controls[self.state]:fct()
			elseif self.state ~= "" and self.controls[self.state] and self.controls[self.state].type=="TextBox" then
				self:okclick()
			end
			self.changed = true
		end,
	}, {
		EXIT = function()
			game:unregisterDialog(self)
			game:bindKeysToStep()
		end
	})
	self:mouseZones{}

	self:addControl(TextBox.new({name="name",title="Name:",min=self.min, max=self.max, x=10, y=5, w=290, h=30}, self, self.font, "name"))
	self:addControl(Button.new("ok", "Ok", 50, 45, 50, 30, self, self.font, function() self:okclick() end))
	self:addControl(Button.new("cancel", "Cancel", 220, 45, 50, 30, self, self.font, function() self:cancelclick() end))
	self:focusControl("name")
end

function _M:okclick()
	local results = self:databind()
	self.name = results.name
	if self.name:len() >= self.min then
		game:unregisterDialog(self)
		self.action(self.name)
	else
		engine.Dialog:simplePopup("Error", "Must be between 2 and 25 characters.")
	end
end

function _M:cancelclick()
	self.key:triggerVirtual("EXIT")
end

function _M:drawDialog(s, w, h)
	self:drawControls(s)
	self.changed = false
end
