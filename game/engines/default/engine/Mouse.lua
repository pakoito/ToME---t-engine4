-- TE4 - T-Engine 4
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	self.areas_name = {}
	self.status = {}
	self.last_pos = { x = 0, y = 0 }
end

--- Called when a mouse is pressed
-- @param button
-- @param x coordinate of the click
-- @param y coordinate of the click
-- @param isup true if the key was released, false if pressed
-- @param force_name if not nil only the zone with this name may trigger
function _M:receiveMouse(button, x, y, isup, force_name, extra)
	self.last_pos = { x = x, y = y }
	self.status[button] = not isup
	if not isup then return end

	if _M.drag then
		if _M.drag.prestart then _M.drag = nil
		else return self:endDrag(x, y) end
	end

	for i  = 1, #self.areas do
		local m = self.areas[i]
		if (not m.mode or m.mode.button) and (x >= m.x1 and x < m.x2 and y >= m.y1 and y < m.y2) and (not force_name or force_name == m.name) then
			m.fct(button, x, y, nil, nil, (x-m.x1) / m.scale, (y-m.y1) / m.scale, "button", extra)
			break
		end
	end
end

function _M:getPos()
	return self.last_pos.x, self.last_pos.y
end

function _M:receiveMouseMotion(button, x, y, xrel, yrel, force_name, extra)
	self.last_pos = { x = x, y = y }
	if _M.drag then
		if _M.drag.on_move then return _M.drag.on_move(_M.drag, button, x, y, xrel, yrel) end
	end

	local cur_m = nil
	for i  = 1, #self.areas do
		local m = self.areas[i]
		if (not m.mode or m.mode.move) and (x >= m.x1 and x < m.x2 and y >= m.y1 and y < m.y2) and (not force_name or force_name == m.name) then
			m.fct(button, x, y, xrel, yrel, (x-m.x1) / m.scale, (y-m.y1) / m.scale, "motion", extra)
			cur_m = m
			break
		end
	end
	if self.last_m and self.last_m.allow_out_events and self.last_m ~= cur_m then
		self.last_m.fct("none", x, y, xrel, yrel, (x-self.last_m.x1) / self.last_m.scale, (y-self.last_m.y1) / self.last_m.scale, "out", extra)
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

--- Returns a zone definition by it's name
function _M:getZone(name)
	return self.areas_name[name]
end

--- Update a named zone with new coords
-- @return true if the zone was found and updated
function _M:updateZone(name, x, y, w, h, fct, scale)
	local m = self.areas_name[name]
	if not m then return false end
	m.scale = scale or m.scale
	m.x1 = x
	m.y1 = y
	m.x2 = x + w * m.scale
	m.y2 = y + h * m.scale
	m.fct = fct or m.fct
	return true
end

--- Registers a click zone that when clicked will call the object's "onClick" method
function _M:registerZone(x, y, w, h, fct, mode, name, allow_out_events, scale)
	scale = scale or 1

	local d = {x1=x,y1=y,x2=x+w * scale,y2=y+h * scale, fct=fct, mode=mode, name=name, allow_out_events=allow_out_events, scale=scale}
	table.insert(self.areas, 1, d)

	if name then self.areas_name[name] = d end
end

function _M:registerZones(t)
	for i, z in ipairs(t) do
		self:registerZone(z.x, z.y, z.w, z.h, z.fct, z.mode, z.name, z.out_events)
	end
end

function _M:unregisterZone(fct)
	if type(fct) == "function" then
		for i  = #self.areas, 1, -1 do
			local m = self.areas[i]
			if m.fct == fct then local m = table.remove(self.areas, i) if m.name then self.areas_name[m.name] = nil end break end
		end
	else
		for i  = #self.areas, 1, -1 do
			local m = self.areas[i]
			if m.name == fct then local m = table.remove(self.areas, i) if m.name then self.areas_name[m.name] = nil end end
		end
	end
end

function _M:reset()
	self.areas = {}
	self.areas_name = {}
end

function _M:startDrag(x, y, cursor, payload, on_done, on_move, no_prestart)
	local start = function()
		_M.drag.prestart = nil
		if _M.drag.cursor then
			local w, h = _M.drag.cursor:getSize()
			_M.drag.cursor = _M.drag.cursor:glTexture()
			core.display.setMouseDrag(_M.drag.cursor, w, h)
		end
		print("[MOUSE] enabling drag from predrag")
	end

	if _M.drag then
		if _M.drag.prestart and math.max(math.abs(_M.drag.start_x - x), math.abs(_M.drag.start_y - y)) > 6 then
			start()
		end
		return
	end

	_M.drag = {start_x=x, start_y=y, payload=payload, on_done=on_done, on_move=on_move, prestart=true, cursor=cursor}
	print("[MOUSE] pre starting drag'n'drop")
	if no_prestart then start() end
end

function _M:endDrag(x, y)
	local drag = _M.drag
	print("[MOUSE] ending drag'n'drop")
	core.display.setMouseDrag(nil, 0, 0)
	_M.drag = nil
	_M.dragged = drag
	_M.current:receiveMouse("drag-end", x, y, true, nil, {drag=drag})
	if drag.on_done then drag.on_done(drag, drag.used) end
	_M.dragged = nil
end

function _M:usedDrag()
	(_M.drag or _M.dragged).used = true
end
