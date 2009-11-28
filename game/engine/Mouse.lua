require "engine.class"

--- Basic mousepress handler
-- The engine calls receiveMouse when a mouse is clicked
module(..., package.seeall, class.make)

function _M:init()
	self.areas = {}
end

--- Called when a mouse is pressed
-- @param button
-- @param x coordinate of the click
-- @param y coordinate of the click
function _M:receiveMouse(button, x, y)
	for i, m in ipairs(self.areas) do
		if (not m.mode or m.mode.button) and (x >= m.x1 and x < m.x2 and y >= m.y1 and y < m.y2) then
			m.fct(button, x, y, nil, nil, x-m.x1, y-m.y1)
		end
	end
end

function _M:receiveMouseMotion(button, x, y, xrel, yrel)
	for i, m in ipairs(self.areas) do
		if (not m.mode or m.mode.move) and (x >= m.x1 and x < m.x2 and y >= m.y1 and y < m.y2) then
			m.fct(button, x, y, xrel, yrel, x-m.x1, y-m.y1)
		end
	end
end

--- Setups as the current game keyhandler
function _M:setCurrent()
	core.mouse.set_current_handler(self)
	_M.current = self
end

--- Registers a click zone that when clicked will call the object's "onClick" method
function _M:registerZone(x, y, w, h, fct, mode)
	table.insert(self.areas, 1, {x1=x,y1=y,x2=x+w,y2=y+h, fct=fct, mode})
end

function _M:registerZones(t)
	for i, z in ipairs(t) do
		self:registerZone(z.x, z.y, z.w, z.h, z.fct, z.mode)
	end
end

function _M:unregisterZone(fct)
	for i, m in ipairs(self.areas) do
		if m.fct == fct then table.remove(self.areas, i) break end
	end
end
