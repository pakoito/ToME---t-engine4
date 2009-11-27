require "engine.class"
require "engine.Tiles"
require "engine.KeyCommand"

--- Handles dialog windows
module(..., package.seeall, class.make)

tiles = engine.Tiles.new(16, 16)

--- Requests a simple, press any key, dialog
function _M:simplePopup(title, text, fct)
	local font = core.display.newFont("/data/font/Vera.ttf", 12)
	local w, h = font:size(text)
	local d = new(title, w + 8, h + 25, nil, nil, nil, font)
	d:keyCommands{__DEFAULT=function() game:unregisterDialog(d) if fct then fct() end end}
	d.drawDialog = function(self, s)
		s:drawColorStringCentered(self.font, text, 2, 2, self.iw - 2, self.ih - 2)
	end
	game:registerDialog(d)
end

--- Create a Dialog
function _M:init(title, w, h, x, y, alpha, font)
	self.title = title
	self.w, self.h = w, h
	self.display_x = x or (game.w - self.w) / 2
	self.display_y = y or (game.h - self.h) / 2
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
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_9.png"), self.w - 8, 0)
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_1.png"), 0, self.h - 8)
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_3.png"), self.w - 8, self.h - 8)
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
	if self.old_key then
		game.key = self.old_key
		game.key:setCurrent()
	end
end
