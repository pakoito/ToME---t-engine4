-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

require "engine.class"
require "engine.ui.Base"
local Slider = require "engine.ui.Slider"

--- Module that handles message history in a mouse wheel scrollable zone
module(..., package.seeall, class.inherit(engine.ui.Base))

--- Creates the log zone
function _M:init(x, y, w, h, max, fontname, fontsize, color, bgcolor)
	self.color = color or {255,255,255}
	if type(bgcolor) ~= "string" then
		self.bgcolor = bgcolor or {0,0,0}
	else
		self.bgcolor = {0,0,0}
		self.bg_image = bgcolor
	end
	self.font = core.display.newFont(fontname or "/data/font/Vera.ttf", fontsize or 12)
	self.font_h = self.font:lineSkip()
	self.log = {}
	getmetatable(self).__call = _M.call
	self.max_log = max or 4000
	self.scroll = 0
	self.changed = true

	self:resize(x, y, w, h)
end

function _M:enableShadow(v)
	self.shadow = v
end

--- Resize the display area
function _M:resize(x, y, w, h)
	self.display_x, self.display_y = math.floor(x), math.floor(y)
	self.w, self.h = math.floor(w), math.floor(h)
	self.fw, self.fh = self.w - 4, self.font:lineSkip()
	self.max_display = math.floor(self.h / self.fh)
	self.changed = true

	if self.bg_image then
		local fill = core.display.loadImage(self.bg_image)
		local fw, fh = fill:getSize()
		self.bg_surface = core.display.newSurface(w, h)
		self.bg_surface:erase(0, 0, 0)
		for i = 0, w, fw do for j = 0, h, fh do
			self.bg_surface:merge(fill, i, j)
		end end
		self.bg_texture, self.bg_texture_w, self.bg_texture_h = self.bg_surface:glTexture()
	end

	self.scrollbar = Slider.new{size=self.h - 20, max=1, inverse=true}
end

--- Appends text to the log
-- This method is set as the call methamethod too, this means it is usable like this:<br/>
-- log = LogDisplay.new(...)<br/>
-- log("foo %s", s)
function _M:call(str, ...)
	str = str:format(...)
	print("[LOG]", str)
	local tstr = str:toString()
	table.insert(self.log, 1, tstr)
	while #self.log > self.max_log do
		table.remove(self.log)
	end
	self.max = #self.log
	self.changed = true
end

--- Clear the log
function _M:empty()
	self.log = {}
	self.changed = true
end

--- Get Last Lines From Log
-- @param number number of lines to retrieve
function _M:getLines(number)
	local from = number
	if from > #self.log then from = #self.log end
	local lines = { }
	for i = from, 1, -1 do
		lines[#lines+1] = tostring(self.log[i])
	end
	return lines
end

function _M:display()
	-- If nothing changed, return the same surface as before
	if not self.changed then return end
	self.changed = false

	-- Erase and the display
	self.dlist = {}
	local h = 0
	local old_style = self.font:getStyle()
	for z = 1 + self.scroll, #self.log do
		local stop = false
		local tstr = self.log[z]
--		local gen = tstring.makeLineTextures(tstr, self.w - 4, self.font)
		local gen = self.font:draw(tstr, self.w, 255, 255, 255)
		for i = #gen, 1, -1 do
			self.dlist[#self.dlist+1] = gen[i]
			h = h + self.fh
			if h > self.h - self.fh then stop=true break end
		end
		if stop then break end
	end
	self.font:setStyle(old_style)
	return
end

function _M:toScreen()
	self:display()
	if self.bg_texture then self.bg_texture:toScreenFull(self.display_x, self.display_y, self.w, self.h, self.bg_texture_w, self.bg_texture_h) end
	local h = self.display_y + self.h -  self.fh
	for i = 1, #self.dlist do
		local item = self.dlist[i]
		if self.shadow then item._tex:toScreenFull(self.display_x+2, h+2, self.fw, self.fh, item._tex_w, item._tex_h, 0,0,0, self.shadow) end
		item._tex:toScreenFull(self.display_x, h, self.fw, self.fh, item._tex_w, item._tex_h)
		h = h - self.fh
	end

	if true then
		self.scrollbar.pos = self.scroll
		self.scrollbar.max = self.max - self.max_display + 1
		self.scrollbar:display(self.display_x + self.w - self.scrollbar.w, self.display_y)
	end
end

--- Scroll the zone
-- @param i number representing how many lines to scroll
function _M:scrollUp(i)
	self.scroll = self.scroll + i
	if self.scroll > #self.log - 1 then self.scroll = #self.log - 1 end
	if self.scroll < 0 then self.scroll = 0 end
	self.changed = true
end
