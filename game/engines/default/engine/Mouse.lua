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

--- Basic mousepress handler
-- The engine calls receiveMouse when a mouse is clicked
module(..., package.seeall, class.make)

function _M:init()
	self.areas = {}
	self.status = {}
end

--- Called when a mouse is pressed
-- @param button
-- @param x coordinate of the click
-- @param y coordinate of the click
-- @param isup true if the key was released, false if pressed
function _M:receiveMouse(button, x, y, isup)
	self.status[button] = not isup
	if not isup then return end

	for i, m in ipairs(self.areas) do
		if (not m.mode or m.mode.button) and (x >= m.x1 and x < m.x2 and y >= m.y1 and y < m.y2) then
			m.fct(button, x, y, nil, nil, x-m.x1, y-m.y1, "button")
			break
		end
	end
end

function _M:receiveMouseMotion(button, x, y, xrel, yrel)
	for i, m in ipairs(self.areas) do
		if (not m.mode or m.mode.move) and (x >= m.x1 and x < m.x2 and y >= m.y1 and y < m.y2) then
			m.fct(button, x, y, xrel, yrel, x-m.x1, y-m.y1, "motion")
			break
		end
	end
end

--- Delegate an event from an other mouse handler
-- if self.delegate_offset_x and self.delegate_offset_y are set hey will be used to change the actual coordinates
function _M:delegate(button, mx, my, xrel, yrel, bx, by, event)
	local ox, oy = (self.delegate_offset_x or 0), (self.delegate_offset_y or 0)
	mx = mx - ox
	my = my - oy

	if event == "button" then self:receiveMouse(button, mx, my, true)
	elseif event == "motion" then self:receiveMouseMotion(button, mx, my, xrel, yrel)
	end
end

--- Setups as the current game keyhandler
function _M:setCurrent()
	core.mouse.set_current_handler(self)
--	if game then game.mouse = self end
	_M.current = self
end

--- Registers a click zone that when clicked will call the object's "onClick" method
function _M:registerZone(x, y, w, h, fct, mode, name)
	table.insert(self.areas, 1, {x1=x,y1=y,x2=x+w,y2=y+h, fct=fct, mode=mode, name=name})
end

function _M:registerZones(t)
	for i, z in ipairs(t) do
		self:registerZone(z.x, z.y, z.w, z.h, z.fct, z.mode, z.name)
	end
end

function _M:unregisterZone(fct)
	for i, m in ipairs(self.areas) do
		if m.fct == fct then table.remove(self.areas, i) break end
	end
end

function _M:reset()
	self.areas = {}
end
