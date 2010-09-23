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
local NumberBox = require "engine.NumberBox"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(title, prompt, default, act)
	engine.Dialog.init(self, title or "Quantity?", 320, 110)
	self.prompt = prompt
	self.act = act
	self.qty = default
	self.first = true
	self:keyCommands({
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
--				self.controls[self.state]:moveRight(1)
			else
				self.state = self:changeFocus(true)
			end
			self.changed = true
		end,
		_LEFT = function()
			if self.state ~= "" and self.controls[self.state] and self.controls[self.state].moveLeft then
--				self.controls[self.state]:moveLeft(1)
			else
				self.state = self:changeFocus(false)
			end
			self.changed = true
		end,
		_BACKSPACE = function()
			if self.state ~= "" and self.controls[self.state] and self.controls[self.state].type=="NumberBox" then
				self.controls[self.state]:backSpace()
			end
			self.changed = true
		end,
		__TEXTINPUT = function(c)
			if self.state ~= "" and self.controls[self.state] and self.controls[self.state].type=="NumberBox" then
				self.controls[self.state]:textInput(c)
			end
			self.changed = true
		end,
		_RETURN = function()
			if self.state ~= "" and self.controls[self.state] and self.controls[self.state].type=="Button" then
				self.controls[self.state]:fct()
			elseif self.state ~= "" and self.controls[self.state] and self.controls[self.state].type=="NumberBox" then
				self:okclick()
			end
			self.changed = true
		end,
	}, {
		EXIT = function()
			game:unregisterDialog(self)
		end
	})
	self:mouseZones{
		{ x=0, y=0, w=game.w, h=game.h, mode={button=true}, norestrict=true, fct=function(button) if button == "left" then game:unregisterDialog(self) end end},
	}

	self:addControl(NumberBox.new({name="qty",title="",min=self.min, max=self.max, default=default, x=10, y=5, w=290, h=30}, self, self.font, "qty"))
	self:addControl(Button.new("ok", "Ok", 50, 45, 50, 30, self, self.font, function() self:okclick() end))
	self:addControl(Button.new("cancel", "Cancel", 220, 45, 50, 30, self, self.font, function() self:cancelclick() end))
	self:focusControl("qty")
end

function _M:okclick()
	local results = self:databind()
	self.qty = results.qty
	self.act(self.qty)
	game:unregisterDialog(self)
end

function _M:cancelclick()
	self.key:triggerVirtual("EXIT")
end

function _M:drawDialog(s, w, h)
	self:drawControls(s)
	self.changed = false
end
