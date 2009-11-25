require "engine.class"
require "engine.Tiles"
require "engine.KeyCommand"

--- Handles dialog windows
module(..., package.seeall, class.make)

tiles = engine.Tiles.new(16, 16)

--- Create a calendar
-- @param definition the file to load that returns a table containing calendar months
-- @param datestring a string to format the date when requested, in the format "%s %s %s %d %d", standing for, day, month, year, hour, minute
function _M:init(title, w, h, x, y, alpha, font)
	self.title = title
	self.w, self.h = w, h
	self.x = x or (game.w - self.w) / 2
	self.y = y or (game.h - self.h) / 2
	self.font = font
	if not font then self.font = core.display.newFont("/data/font/Vera.ttf", 12) end
	self.surface = core.display.newSurface(w, h)
	self.iw, self.ih = w - 2 * 5, h - 8 - 16 - 3
	self.internal_surface = core.display.newSurface(self.iw, self.ih)
	self.surface:alpha(alpha or 220)
	self.changed = true
end

function _M:display()
	if not self.changed then return self.surface end

	local s = self.surface
	s:erase()

	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_7.png"), 0, 0)
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_9.png"), self.w - 9, 0)
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_1.png"), 0, self.h - 9)
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_3.png"), self.w - 9, self.h - 9)
	for i = 8, self.w - 9 do
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_8.png"), i, 0)
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_8.png"), i, 20)
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_8.png"), i, self.h - 3)
	end
	for i = 8, self.h - 9 do
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_4.png"), 0, i)
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_4.png"), self.w - 3, i)
	end

	local tw, th = self.font:size(self.title)
	s:drawColorString(self.font, self.title, (self.w - tw) / 2, 4, 255,255,255)

	self.internal_surface:erase()
	self:drawDialog(self.internal_surface)
	s:merge(self.internal_surface, 5, 20 + 3)

	return self.surface
end

function _M:drawDialog(s)
end

function _M:keyCommands(t)
	self.old_key = game.key
	game.key = engine.KeyCommand.new()
	game.key:addCommands(t)
	game.key:setCurrent()
end

function _M:unload()
	game.key = self.old_key
	game.key:setCurrent()
end
