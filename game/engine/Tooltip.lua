require "engine.class"
local Map = require "engine.Map"

--- Displays a tooltip
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

--- Set the tooltip text
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

	-- Erase and the display the tooltip
	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3], 200)

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

--- Displays the tooltip at the given map coordinates
-- @param tmx the map coordinate to get tooltip from
-- @param tmy the map coordinate to get tooltip from
-- @param mx the screen coordinate to display at, if nil it will be computed from tmx
-- @param my the screen coordinate to display at, if nil it will be computed from tmy
function _M:displayAtMap(tmx, tmy, mx, my)
	if not mx then
		mx, my = game.level.map:getTileToScreen(tmx, tmy)
	end

	local tt = game.level.map:checkEntity(tmx, tmy, Map.ACTOR, "tooltip") or
			game.level.map:checkEntity(tmx, tmy, Map.OBJECT, "tooltip") or
			game.level.map:checkEntity(tmx, tmy, Map.TRAP, "tooltip") or
			game.level.map:checkEntity(tmx, tmy, Map.TERRAIN, "tooltip")
	if tt and game.level.map.seens(tmx, tmy) then
		self:set("%s", tt)
		local t = self:display()
		mx = mx - self.w
		my = my - self.h
		if mx < 0 then mx = 0 end
		if my < 0 then my = 0 end
		if t then t:toScreen(mx, my) end
	end
end
