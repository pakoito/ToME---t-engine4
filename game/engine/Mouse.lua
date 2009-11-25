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
		if x >= m.x1 and x < m.x2 and y >= m.y1 and y < m.y2 then
			m.fct(button, x, y)
		end
	end
end

--- Setups as the current game keyhandler
function _M:setCurrent()
	core.mouse.set_current_handler(self)
	_M.current = self
end

--- Registers a click zone that when clicked will call the object's "onClick" method
function _M:registerZoneClick(x, y, w, h, fct)
	table.insert(self.areas, {x1=x,y1=y,x2=x+w,y2=y+h, fct=fct})
end

function _M:unregisterZoneClick(fct)
	for i, m in ipairs(self.areas) do
		if m.obj == obj then self.areas[fct] = nil break end
	end
end
