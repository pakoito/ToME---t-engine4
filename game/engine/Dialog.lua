require "engine.class"
require "engine.Tiles"
require "engine.KeyBind"

--- Handles dialog windows
module(..., package.seeall, class.make)

tiles = engine.Tiles.new(16, 16)

--- Requests a simple, press any key, dialog
function _M:simplePopup(title, text, fct)
	local font = core.display.newFont("/data/font/Vera.ttf", 12)
	local w, h = font:size(text)
	local d = new(title, w + 8, h + 25, nil, nil, nil, font)
	d:keyCommands{__DEFAULT=function() game:unregisterDialog(d) if fct then fct() end end}
	d:mouseZones{{x=0, y=0, w=game.w, h=game.h, fct=function(b) if b ~= "none" then game:unregisterDialog(d) if fct then fct() end end end, norestrict=true}}
	d.drawDialog = function(self, s)
		s:drawColorStringCentered(self.font, text, 2, 2, self.iw - 2, self.ih - 2)
	end
	game:registerDialog(d)
	return d
end

--- Create a Dialog
function _M:init(title, w, h, x, y, alpha, font)
	self.title = title
	self.w, self.h = w, h
	self.display_x = x or (game.w - self.w) / 2
	self.display_y = y or (game.h - self.h) / 2
	self.font = font
	if not font then self.font = core.display.newFont("/data/font/Vera.ttf", 12) end
	self.font_h = self.font:lineSkip()
	self.surface = core.display.newSurface(w, h)
	self.iw, self.ih = w - 2 * 5, h - 8 - 16 - 3
	self.internal_surface = core.display.newSurface(self.iw, self.ih)
	self.surface:alpha(alpha or 220)
	self.texture = self.surface:glTexture()
	self.changed = true
end

function _M:display()
	if not self.changed then return self.surface end

	local s = self.surface
	s:erase(0,0,0,200)

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

function _M:toScreen(x,y)
	self.surface:toScreenWithTexture(self.texture,x,y)
end

function _M:drawDialog(s)
end

function _M:keyCommands(t, b)
	self.old_key = game.key
	game.key = engine.KeyBind.new()
	if t then game.key:addCommands(t) end
	if b then game.key:addBinds(b) end
	game.key:setCurrent()
	self.key = game.key
end

function _M:mouseZones(t)
	-- Offset the x and y with the window position and window title
	if not t.norestrict then
		for i, z in ipairs(t) do
			z.x = z.x + self.display_x + 5
			z.y = z.y + self.display_y + 20 + 3
		end
	end

	self.old_mouse = game.mouse
	game.mouse = engine.Mouse.new()
	game.mouse:registerZones(t)
	game.mouse:setCurrent()
end

function _M:unload()
	if self.old_key then
		game.key = self.old_key
		game.key:setCurrent()
	end
	if self.old_mouse then
		game.mouse = self.old_mouse
		game.mouse:setCurrent()
	end
end

function _M:drawWBorder(s, x, y, w)
	for i = x, x + w do
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_8.png"), i, y)
	end
end
function _M:drawHBorder(s, x, y, h)
	for i = y, y + h do
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_4.png"), x, i)
	end
end

function _M:drawSelectionList(s, x, y, hskip, list, sel, prop, scroll, max)
	scroll = scroll or 1
	max = max or 99999

	for i = scroll, math.min(#list, scroll + max - 1) do
		v = list[i]
		if prop then v = tostring(v[prop])
		else v = tostring(v) end
		if sel == i then
			s:drawColorString(self.font, v, x, y + (i-scroll) * hskip, 0, 255, 255)
		else
			s:drawColorString(self.font, v, x, y + (i-scroll) * hskip)
		end
	end
end
