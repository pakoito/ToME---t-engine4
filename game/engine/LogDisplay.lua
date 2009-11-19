require "engine.class"

module(..., package.seeall, class.make)

function _M:init(w, h, max, fontname, fontsize, color)
	self.color = color or {255,255,255}
	self.w, self.h = w, h
	self.font = core.display.newFont(fontname or "/data/font/Vera.ttf", fontsize or 10)
	self.surface = core.display.newSurface(w, h)
	self.log = {}
	getmetatable(self).__call = _M.call
	self.max = max or 400
	self.changed = true
end

function _M:call(str, ...)
	table.insert(self.log, 1, str:format(...))
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
	self.surface:erase()
	local i = 1
	while i < self.h do
		if not self.log[i] then break end
		self.surface:drawString(self.font, self.log[i], 0, (i-1) * 16, self.color[1], self.color[2], self.color[3])
		i = i + 1
	end
	return self.surface
end
