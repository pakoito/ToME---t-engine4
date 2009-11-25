require "engine.class"

module(..., package.seeall, class.make)

tiles = engine.Tiles.new(16, 16)

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
	self.w, self.h = 0, 0
	for i, l in ipairs(self.text) do
		local w, h = self.font:size(l)
		if w > self.w then self.w = w end
		self.h = self.h + self.font_h
	end
	self.w = self.w + 8
	self.h = self.h + 8
	self.changed = true
end

function _M:display()
	-- If nothing changed, return the same surface as before
	if not self.changed then return self.surface end
	self.changed = false

	self.surface = core.display.newSurface(self.w, self.h)
	self.surface:alpha(200)

	-- Erase and the display the tooltip
	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])

	self.surface:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_7.png"), 0, 0)
	self.surface:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_9.png"), self.w - 8, 0)
	self.surface:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_1.png"), 0, self.h - 8)
	self.surface:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_3.png"), self.w - 8, self.h - 8)
	for i = 8, self.w - 9 do
		self.surface:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_8.png"), i, 0)
		self.surface:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_8.png"), i, self.h - 3)
	end
	for i = 8, self.h - 9 do
		self.surface:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_4.png"), 0, i)
		self.surface:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_4.png"), self.w - 3, i)
	end

	for i, l in ipairs(self.text) do
		self.surface:drawColorString(self.font, self.text[i], 4, 4 + (i-1) * self.font_h, self.color[1], self.color[2], self.color[3])
	end
	return self.surface
end
