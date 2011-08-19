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
-- @param force_name if not nil only the zone with this name may trigger
function _M:receiveMouse(button, x, y, isup, force_name, extra)
	self.status[button] = not isup
	if not isup then return end

	if _M.drag then
		if _M.drag.prestart then _M.drag = nil
		else return self:endDrag(x, y) end
	end

	for i, m in ipairs(self.areas) do
		if (not m.mode or m.mode.button) and (x >= m.x1 and x < m.x2 and y >= m.y1 and y < m.y2) and (not force_name or force_name == m.name) then
			m.fct(button, x, y, nil, nil, x-m.x1, y-m.y1, "button", extra)
			break
		end
	end
end

function _M:receiveMouseMotion(button, x, y, xrel, yrel, force_name, extra)
	local cur_m = nil
	for i, m in ipairs(self.areas) do
		if (not m.mode or m.mode.move) and (x >= m.x1 and x < m.x2 and y >= m.y1 and y < m.y2) and (not force_name or force_name == m.name) then
			m.fct(button, x, y, xrel, yrel, x-m.x1, y-m.y1, "motion", extra)
			cur_m = m
			break
		end
	end
	if self.last_m and self.last_m.allow_out_events and self.last_m ~= cur_m then
		self.last_m.fct("none", x, y, xrel, yrel, x-self.last_m.x1, y-self.last_m.y1, "out", extra)
	end
	self.last_m = cur_m
end

--- Delegate an event from an other mouse handler
-- if self.delegate_offset_x and self.delegate_offset_y are set hey will be used to change the actual coordinates
function _M:delegate(button, mx, my, xrel, yrel, bx, by, event, name, extra)
	local ox, oy = (self.delegate_offset_x or 0), (self.delegate_offset_y or 0)
	mx = mx - ox
	my = my - oy

	if event == "button" then self:receiveMouse(button, mx, my, true, name, extra)
	elseif event == "motion" then self:receiveMouseMotion(button, mx, my, xrel, yrel, name, extra)
	end
end

--- Setups as the current game keyhandler
function _M:setCurrent()
	core.mouse.set_current_handler(self)
--	if game then game.mouse = self end
	_M.current = self
end

--- Registers a click zone that when clicked will call the object's "onClick" method
function _M:registerZone(x, y, w, h, fct, mode, name, allow_out_events)
	table.insert(self.areas, 1, {x1=x,y1=y,x2=x+w,y2=y+h, fct=fct, mode=mode, name=name, allow_out_events=allow_out_events})
end

function _M:registerZones(t)
	for i, z in ipairs(t) do
		self:registerZone(z.x, z.y, z.w, z.h, z.fct, z.mode, z.name, z.out_events)
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

function _M:startDrag(x, y, cursor, payload, on_done)
	if _M.drag then
		if _M.drag.prestart and math.max(math.abs(_M.drag.start_x - x), math.abs(_M.drag.start_y - y)) > 6 then
			_M.drag.prestart = nil
			if _M.drag.cursor then game:setMouseCursor(_M.drag.cursor, nil, 0, 0) end
			print("[MOUSE] enabling drag from predrag")
		end
		return
	end

	_M.drag = {start_x=x, start_y=y, payload=payload, on_done=on_done, prestart=true, cursor=cursor}
	print("[MOUSE] pre starting drag'n'drop")
end

function _M:endDrag(x, y)
	local drag = _M.drag
	print("[MOUSE] ending drag'n'drop")
	game:defaultMouseCursor()
	_M.drag = nil
	_M.dragged = drag
	_M.current:receiveMouse("drag-end", x, y, true, nil, {drag=drag})
	if drag.on_done then drag.on_done(drag, drag.used) end
	_M.dragged = nil
end

function _M:usedDrag()
	(_M.drag or _M.dragged).used = true
end
