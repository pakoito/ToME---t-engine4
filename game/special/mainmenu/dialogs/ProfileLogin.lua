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

function _M:init(dialogdef)
	engine.Dialog.init(self, "Profile Login "..dialogdef.name, 500, 400)	
	self.dialogdef = dialogdef
	self.alpha = 230
	self.justlogin = dialogdef.justlogin
	
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
	self:addControl(Button.new("ok", "Ok", 50, 330, 50, 30, self, self.font, function() self:okclick() end))
	self:addControl(Button.new("cancel", "Canel", 400, 330, 50, 30, self, self.font, function() self:cancelclick() end))
	self:addControl(TextBox.new({name="login",title="You Login:",min=2, max=25, x=30, y=30, w=350, h=30}, self, self.font, "login name"))
	self:addControl(TextBox.new({name="pass",title="Password:",min=2, max=25, x=30, y=70, w=350, h=30}, self, self.font, "password"))
	if not self.justlogin then
		self:addControl(TextBox.new({name="email",title="Email Address:",min=2, max=25, x=30, y=110, w=350, h=30}, self, self.font, "email address"))
		self:addControl(TextBox.new({name="name",title="Name:",min=2, max=25, x=30, y=150, w=350, h=30}, self, self.font, "name"))
	end
	self:focusControl("login")	
end


function _M:okclick()
	game:unregisterDialog(self) 
	results = self:databind()	
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
	local y = 200
	local x = 30
	lines = { "What's the online profile for?", "* Playing from several computers without copying and worries.", "* Keep track of your modules progression.", "* For Example Kill Count, Unlockables unlocked and achievments in TOME", "* Unlimited possibilites for migrating your module information.", "* Cool statistics for each module to help sharpen your gameplay style", "* Who doesn't like statistics?"}
	for i = 1, #lines do
		r, g, b = s:drawColorStringBlended(self.font, lines[i], x, y + i * self.font:lineSkip(), r, g, b)		
	end	
	self:drawControls(s)	
end

function _M:close()
	if self.old_key then self.old_key:setCurrent() end
	if self.old_mouse then self.old_mouse:setCurrent() end
end
