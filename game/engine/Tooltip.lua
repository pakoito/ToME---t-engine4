require "engine.class"

module(..., package.seeall, class.make)

function _M:init(fontname, fontsize, color, bgcolor)
	self.color = color or {255,255,255}
	self.bgcolor = bgcolor or {0,0,0}
	self.w, self.h = w, h
	self.font = core.display.newFont(fontname or "/data/font/Vera.ttf", fontsize or 10)
	self.font_h = self.font:lineSkip()
	self.max = max or 400
	self.changed = true
end

function _M:set(str, ...)
	self.text = str:format(...)
	self.changed = true
end

function _M:display()
	-- If nothing changed, return the same surface as before
	if not self.changed then return self.surface end
	self.changed = false

	local w, h = self.font:size(self.text)
	self.surface = core.display.newSurface(w + 4, h + 4)

	-- Erase and the display the map
	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])
	self.surface:drawString(self.font, self.text, 0, 0, self.color[1], self.color[2], self.color[3])
	return self.surface
end
