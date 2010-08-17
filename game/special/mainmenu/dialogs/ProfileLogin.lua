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
local ButtonList = require "engine.ButtonList"
local Button = require "engine.Button"
local TextBox = require "engine.TextBox"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(dialogdef, profile_help_text)
	engine.Dialog.init(self, "Online profile "..dialogdef.name, 500, dialogdef.justlogin and 450 or 550)
	self.profile_help_text = profile_help_text
	self.dialogdef = dialogdef
	self.alpha = 230
	self.justlogin = dialogdef.justlogin

	self.lines = self.profile_help_text:splitLines(self.iw - 60, self.font)

	self:keyCommands({
		_DELETE = function()
			if self.controls[self.state] and self.controls[self.state].delete then
				self.controls[self.state]:delete()
			end
		end,
		_TAB = function()
			self.state = self:changeFocus(true)
		end,
		_DOWN = function()
			self.state = self:changeFocus(true)
		end,
		_UP = function()
			self.state = self:changeFocus(false)
		end,
		_RIGHT = function()
			if self.state ~= "" and self.controls[self.state] and self.controls[self.state].moveRight then
				self.controls[self.state]:moveRight(1)
			else
				self.state = self:changeFocus(true)
			end
		end,
		_LEFT = function()
			if self.state ~= "" and self.controls[self.state] and self.controls[self.state].moveLeft then
				self.controls[self.state]:moveLeft(1)
			else
				self.state = self:changeFocus(false)
			end
		end,
		_BACKSPACE = function()
			if self.state ~= "" and self.controls[self.state] and self.controls[self.state].type=="TextBox" then
				self.controls[self.state]:backSpace()
			end
		end,
		__TEXTINPUT = function(c)
			if self.state ~= "" and self.controls[self.state] and self.controls[self.state].type=="TextBox" then
				self.controls[self.state]:textInput(c)
			end
		end,
		_RETURN = function()
			if self.state ~= "" and self.controls[self.state] and self.controls[self.state].type=="Button" then
				self.controls[self.state]:fct()
			end
		end,
					}, {
		EXIT = function()
			game:unregisterDialog(self)
			game:selectStepProfile()
		end
	})
	self:setMouseHandling()

	local basey = #self.lines * self.font:lineSkip() + 25

	self:addControl(TextBox.new({name="login",title="Login:",min=2, max=25, x=30, y=basey + 5, w=350, h=30}, self, self.font, "login name"))
	self:addControl(TextBox.new({name="pass",title ="Password:",min=2, max=25, x=30, y=basey + 45, w=350, h=30, private=true}, self, self.font, "password"))
	if not self.justlogin then
		self:addControl(TextBox.new({name="email",title="Email Address:",min=2, max=25, x=30, y=basey + 85, w=350, h=30}, self, self.font, "email address"))
		self:addControl(TextBox.new({name="name",title="Name:",min=2, max=25, x=30, y=basey + 125, w=350, h=30}, self, self.font, "name"))
		self:addControl(Button.new("ok", "Ok", 50, basey + 165, 50, 30, self, self.font, function() self:okclick() end))
		self:addControl(Button.new("cancel", "Canel", 400, basey + 165, 50, 30, self, self.font, function() self:cancelclick() end))
		self:resize(500, basey + 225)
	else
		self:addControl(Button.new("ok", "Ok", 50, basey + 85, 50, 30, self, self.font, function() self:okclick() end))
		self:addControl(Button.new("cancel", "Canel", 400, basey + 85, 50, 30, self, self.font, function() self:cancelclick() end))
		self:resize(500, basey + 145)
	end
	self:focusControl("login")
end


function _M:okclick()
	game:unregisterDialog(self)
	local results = self:databind()
	game:selectStepProfile()
	game:createProfile(results)
end

function _M:cancelclick()
	game:unregisterDialog(self)
	game:selectStepProfile()
end

function _M:setMouseHandling()
	self.old_mouse = engine.Mouse.current
	self.mouse = engine.Mouse.new()
	self.mouse:setCurrent()
	game.mouse = self.mouse
end


function _M:drawDialog(s, w, h)
	local y = 5
	local x = 30
	local r, g, b
	for i = 1, #self.lines do
		r, g, b = s:drawColorStringBlended(self.font, self.lines[i], x, y + i * self.font:lineSkip(), r, g, b)
	end
	self:drawControls(s)
end

function _M:close()
	if self.old_key then self.old_key:setCurrent() end
	if self.old_mouse then self.old_mouse:setCurrent() end
end
