require "engine.class"
require "engine.Tiles"
require "engine.Mouse"
require "engine.KeyCommand"

--- Handles dialog windows
module(..., package.seeall, class.make)

tiles = engine.Tiles.new(16, 16)

--- Create a buttons list
function _M:init(list, x, y, w, h, font, separator)
	self.separator = separator or 20
	self.w, self.h = w, h
	self.display_x = x or (game.w - self.w) / 2
	self.display_y = y or (game.h - self.h) / 2
	self.font = font
	self.list = list
	if not font then self.font = core.display.newFont("/data/font/VeraBd.ttf", 16) end
	self.surface = core.display.newSurface(w, h)
	self.texture = self.surface:glTexture()
	self.surface:erase()

	self.selected = 0
	self:select(1)

	for i, b in ipairs(self.list) do
		assert(b.name, "no button name")
		assert(b.fct, "no button function")
		local bw, bh = (b.font or self.font):size(b.name)
		b.w, b.h = w, h / (#list + 1)
		b.susel = self:makeButton(b.name, b.font, b.w, b.h, false)
		b.ssel = self:makeButton(b.name, b.font, b.w, b.h, true)
		b.mouse_over = function(button)
			self:select(i)

			if button == "left" then
				self:click(i)
			end
		end
	end

	self.changed = true
end

function _M:close()
	if self.old_key then self.old_key:setCurrent() end
	if self.old_mouse then self.old_mouse:setCurrent() end
end

function _M:setKeyHandling()
	self.old_key = engine.KeyCommand.current
	self.key = engine.KeyCommand.new()
	self.key:setCurrent()
	self.key:addCommands
	{
		_UP = function()
			self:select(-1, true)
		end,
		_DOWN = function()
			self:select(1, true)
		end,
		_RETURN = function()
			self:click()
		end,
	}
end

function _M:setMouseHandling()
	self.old_mouse = engine.Mouse.current
	self.mouse = engine.Mouse.new()
	self.mouse:setCurrent()
	for i, b in ipairs(self.list) do
		self.mouse:registerZone(self.display_x, self.display_y + (i - 1) * (b.h + self.separator), b.w, b.h, b.mouse_over)
	end
end

function _M:select(i, offset)
	self.old_selected = self.selected

	if offset then
		self.selected = self.selected + i
	else
		self.selected = i
	end
	if self.selected > #self.list then self.selected = 1 end
	if self.selected < 1 then self.selected = #self.list end
	if old ~= self.selected and self.list[self.selected].onSelect then self.list[self.selected].onSelect() end
	self.changed = true
end

function _M:skipSelected()
	if self.old_selected < self.selected then self:select(-1, true)
	elseif self.old_selected > self.selected then self:select(1, true) end
end

function _M:click(i)
	self.list[i or self.selected].fct()
end

function _M:display()
	if not self.changed then return self.surface end

	self.surface:erase()
	for i, b in ipairs(self.list) do
		if i == self.selected then
			self.surface:merge(b.ssel, 0, (i - 1) * (b.h + self.separator))
		else
			self.surface:merge(b.susel, 0, (i - 1) * (b.h + self.separator))
		end
	end

	return self.surface
end

function _M:toScreen(x,y)
	self.surface:toScreenWithTexture(self.texture,x,y)
end

function _M:makeButton(name, font, w, h, sel)
	font = font or self.font
	local s = core.display.newSurface(w, h)
	if sel then
		s:erase(143, 155, 85, 200)
	end
	s:erase(0,0,0,200)

	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_7"..(sel and "_sel" or "")..".png"), 0, 0)
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_9"..(sel and "_sel" or "")..".png"), w - 8, 0)
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_1"..(sel and "_sel" or "")..".png"), 0, h - 8)
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_3"..(sel and "_sel" or "")..".png"), w - 8, h - 8)
	for i = 8, w - 9 do
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_8.png"), i, 0)
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_8.png"), i, h - 3)
	end
	for i = 8, h - 9 do
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_4.png"), 0, i)
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_4.png"), w - 3, i)
	end

	local sw, sh = font:size(name)
	s:drawColorString(font, name, (w - sw) / 2, (h - sh) / 2)

	return s
end
