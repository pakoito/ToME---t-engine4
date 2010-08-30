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
require "engine.Tiles"
require "engine.Mouse"
require "engine.KeyBind"
local ButtonList = require "engine.ButtonList"

--- Handles dialog windows
module(..., package.seeall, class.make)

function _M:init(name, text, x, y, w, height, owner, font, fct)	
	self.type = "Button"
	self.owner = owner
	self.name = name	
	self.fct = fct
	self.font = font	
	self.x = x
	self.y = y
	self.btn = 	{ 
		susel = ButtonList:makeButton(text, self.font, w, height, false),
		sel = ButtonList:makeButton(text, self.font, 50, height, true),
		h = height,
		mouse_over= function(button)							
						if self.owner.state ~= self.name then self.owner:focusControl(self.name) end						
						if button == "left" then
							self:fct()
						end
					end
					}
	self.owner.mouse:registerZone(owner.display_x + self.x, owner.display_y + self.y + height, w, height, self.btn.mouse_over)	
end

function _M:drawControl(s)	
	if (self.owner.state == self.name) then
		s:merge(self.btn.sel, self.x, self.y)		
	else
		s:merge(self.btn.susel, self.x, self.y)				
	end	
end