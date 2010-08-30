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
require "engine.interface.ControlCursorSupport"
--- Handles textbox input control
module(..., package.seeall, class.inherit(
		engine.interface.ControlCursorSupport))

tiles = engine.Tiles.new(16, 16)

function _M:init(dialogdef, owner, font, mask, fct)
	--name, title, min, max, x, y, w, height
	self.type = "TextBox"
	self.name = dialogdef.name
	self.title = dialogdef.title
	self.min = dialogdef.min or 2
	self.max = dialogdef.max or 25
	self.h = dialogdef.h or 30
	self.font = font
	self.w = dialogdef.w or 200
	self.x = dialogdef.x
	self.y = dialogdef.y
	self.private = dialogdef.private
	self.text = ""
	self.owner = owner
	self.btn = 	{
		h = dialogdef.h,
		mouse_over= function(button)
						if self.owner.state ~= self.name then self.focused=true self.owner:focusControl(self.name) end
						if button == "right" then
							self.text=""
							self.ownwer.changed=true
						end
					end
				}
	self.owner.mouse:registerZone(self.owner.display_x + self.x, self.owner.display_y + self.y + self.h, self.w, self.h, self.btn.mouse_over)
	self:startCursor()
end

function _M:delete()
	if (self.cursorPosition>=self.maximumCurosrPosition) then return end
	local temptext = self.text:sub(1, self.cursorPosition)
	if self.cursorPosition < self.maximumCurosrPosition - 1 then temptext = temptext..self.text:sub(self.cursorPosition + 2, self.text:len()) end
	self.text =  temptext
	self.maximumCurosrPosition = self.maximumCurosrPosition - 1
end

function _M:backSpace()
	if (self.cursorPosition==0) then return end
	local temptext = self.text:sub(1, self.cursorPosition - 1)
	if self.cursorPosition < self.maximumCurosrPosition then temptext = temptext..self.text:sub(self.cursorPosition + 1, self.text:len()) end
	self.text =  temptext
	self.maximumCurosrPosition = self.maximumCurosrPosition - 1
	self.cursorPosition = self.cursorPosition - 1
end

function _M:textInput(c)
	if self.text:len() < self.max then
		local temp=nil
		if self.cursorPosition < self.maximumCurosrPosition then temp=self.text:sub(self.cursorPosition + 1, self.text:len()) end
		self.text = self.text:sub(1,self.cursorPosition) .. c
		if temp then self.text=self.text..temp end
		self.owner.changed = true
		self:moveRight(1, true)
	end
end

function _M:unFocus()
	self.focused = false
end


function _M:drawControl(s)

	local r, g, b
	local w = self.w
	local h = self.h
	local tw, th = self.font:size(self.title)
	tw = tw + 10
	local title=self.title
	if self.owner.state==self.name then
		title = title.."*"
	end
	r, g, b = s:drawColorStringBlended(self.font, title, self.x, self.y + ((h - th) / 2), r, g, b)

	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_7"..(sel and "_sel" or "")..".png"), self.x + tw, self.y)
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_9"..(sel and "_sel" or "")..".png"), w + self.x - 8, self.y)
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_1"..(sel and "_sel" or "")..".png"), self.x + tw, self.y + h - 8)
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_3"..(sel and "_sel" or "")..".png"), self.x + w - 8, self.y + h - 8)
	for i = 8, w - tw - 9 do
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_8.png"), self.x + tw + i, self.y)
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_8.png"), self.x + tw + i, self.y + h - 3)
	end
	for i = 8, h - 9 do
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_4.png"), self.x + tw, self.y + i)
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_4.png"), self.x + w - 3, self.y + i)
	end

	local text = self.text
	if text=="" then text=self.mask or "" end
	if self.private then text = text:gsub('.', '*') end
	local sw, sh = self.font:size(text)

	local baseX = self.x + tw + 10

	s:drawColorStringBlended(self.font, text, baseX, self.y + h - sh - 8)
	self:drawCursor(s, baseX, text)
end
