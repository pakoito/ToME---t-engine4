require "engine.class"

module(..., package.seeall, class.make)

function _M:init(x, y, w, h, max, fontname, fontsize, color, bgcolor)
	self.color = color or {255,255,255}
	self.bgcolor = bgcolor or {0,0,0}
	self.display_x, self.display_y = x, y
	self.w, self.h = w, h
	self.font = core.display.newFont(fontname or "/data/font/Vera.ttf", fontsize or 10)
	self.font_h = self.font:lineSkip()
	self.surface = core.display.newSurface(w, h)
	self.log = {}
	getmetatable(self).__call = _M.call
	self.max = max or 4000
	self.scroll = 0
	self.changed = true
end

function _M:call(str, ...)
	local lines = str:format(...):splitLines(self.w - 4, self.font)
	for i = 1, #lines do
		print("[LOG]", lines[i])
		table.insert(self.log, 1, lines[i])
	end
	while #self.log > self.max do
		table.remove(self.log)
	end
	self.changed = true
end

function _M:empty()
	self.log = {}
	self.changed = true
end

function _M:display()
	-- If nothing changed, return the same surface as before
	if not self.changed then return self.surface end
	self.changed = false

	-- Erase and the display the map
	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])
	local i, dh = 1, 0
	while i < self.h do
		if not self.log[self.scroll + i] then break end
		self.surface:drawColorString(self.font, self.log[self.scroll + i], 0, self.h - (i) * self.font_h, self.color[1], self.color[2], self.color[3])
		i = i + 1
		dh = dh + self.font_h
	end
	return self.surface
end

function _M:scrollUp(i)
	self.scroll = self.scroll + i
	if self.scroll > #self.log - 1 then self.scroll = #self.log - 1 end
	if self.scroll < 0 then self.scroll = 0 end
	self.changed = true
end
