require "engine.class"

module(..., package.seeall, class.make)

function _M:init(fontname, fontsize, color, bgcolor)
	self.color = color or {255,255,255}
	self.bgcolor = bgcolor or {0,0,0}
	self.font = core.display.newFont(fontname or "/data/font/Vera.ttf", fontsize or 10)
	self.font_h = self.font:lineSkip()
	self.max = max or 400
	self.changed = true
end

function _M:set(str, ...)
	self.text = str:format(...):splitLines(300, self.font)
	self.changed = true
end

function _M:display()
	-- If nothing changed, return the same surface as before
	if not self.changed then return self.surface end
	self.changed = false

	self.surface = core.display.newSurface(300, self.font_h * #self.text)

	-- Erase and the display the map
	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])
	for i, l in ipairs(self.text) do
		self.surface:drawColorString(self.font, self.text[i], 0, (i-1) * self.font_h, self.color[1], self.color[2], self.color[3])
	end
	return self.surface
end
