require "engine.class"

--- Module that handles a single message line, with pausing and flashing
module(..., package.seeall, class.make)

GOOD = 1
NEUTRAL = 2
BAD = 3

--- Creates the log zone
function _M:init(x, y, w, h, max, fontname, fontsize, color, bgcolor)
	self.color = color or {255,255,255}
	self.bgcolor = bgcolor or {0,0,0}
	self.display_x, self.display_y = x, y
	self.w, self.h = w, h
	self.font = core.display.newFont(fontname or "/data/font/Vera.ttf", fontsize or 16)
	self.font_h = self.font:lineSkip()
	self.surface = core.display.newSurface(w, h)
	self.log = {}
	getmetatable(self).__call = _M.call
	self.flashing_style = NEUTRAL
	self.flashing = 0
	self.changed = true
end

--- Appends text to the log
-- This method is set as the call methamethod too, this means it is usable like this:<br/>
-- log = LogDisplay.new(...)<br/>
-- log("foo %s", s)
function _M:call(style, str, ...)
	if self.flashing == 0 and #self.log > 0 then self.log = {} end

	local base = ""
	if #self.log > 0 then base = table.remove(self.log) end

	local lines = (base .. " " .. str:format(...)):splitLines(self.w - 4, self.font)
	for i = 1, #lines do
		table.insert(self.log, lines[i])
	end
	self.flashing_style = style
	self.flashing = 20
	self.changed = true
end

--- Clear the log
function _M:empty(force)
	if self.flashing == 0 or force then
		self.log = {}
		self.flashing = 0
		self.changed = true
	end
end

function _M:display()
	-- If nothing changed, return the same surface as before
	if not self.changed then return self.surface end
	self.changed = false

	-- Erase and the display the map
	if self.flashing_style == BAD then
		self.surface:erase(self.bgcolor[1] + self.flashing * 10, self.bgcolor[2], self.bgcolor[3])
	elseif self.flashing_style == NEUTRAL then
		self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3] + self.flashing * 10)
	else
		self.surface:erase(self.bgcolor[1], self.bgcolor[2] + self.flashing * 10, self.bgcolor[3])
        end
	self.surface:drawColorString(self.font, self.log[1] or "", 0, 0, self.color[1], self.color[2], self.color[3])

	self.flashing = self.flashing - 1
	if self.flashing > 0 then self.changed = true
	else table.remove(self.log, 1) end

	return self.surface
end
