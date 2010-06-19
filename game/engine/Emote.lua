-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
require "engine.Tiles"

module(..., package.seeall, class.make)

local font = core.display.newFont(fontname or "/data/font/VeraBd.ttf", 16)
local tiles = engine.Tiles.new(16, 16)

function _M:init(text, dur, color)
	local w, h = font:size(text)
	w = w + 10
	h = h + 15
	self.dur = dur or 30
	color = color or {r=0, g=0, b=0}

	local s = core.display.newSurface(w, h)
	if not s then return end
	s:erase(0, 0, 0, 255)

	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "emote/7.png"), 0, 0)
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "emote/9.png"), w - 6, 0)
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "emote/1.png"), 0, h - 10)
	s:merge(tiles:get(nil, 0,0,0, 0,0,0, "emote/3.png"), w - 6, h - 10)
	for i = 6, w - 6 do
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "emote/8.png"), i, 0)
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "emote/2.png"), i, h - 10)
	end
	for i = 6, h - 10 do
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "emote/4.png"), 0, i)
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "emote/6.png"), w - 6, i)
	end
	s:erase(255, 255, 255, 255, 6, 6, w - 6 - 6, h - 10 - 6)
	s:erase(0, 0, 0, 0, 6, h - 4, w - 6, 4)

	s:drawStringBlended(font, text, 5, 5, color.r, color.g, color.b)

	self.text = text
	self.w = w
	self.h = h
	self.surface = s
end

function _M:update()
	self.dur = self.dur - 1
	if self.dur < 0 then return true end
end
