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
local Map = require "engine.Map"

--- Displays a tooltip
module(..., package.seeall, class.make)

tiles = engine.Tiles.new(16, 16)

function _M:init(fontname, fontsize, color, bgcolor, max)
	self.color = color or {255,255,255}
	self.bgcolor = bgcolor or {0,0,0}
	self.font = core.display.newFont(fontname or "/data/font/Vera.ttf", fontsize or 12)
	self.font_h = self.font:lineSkip()
	self.max = max or 300
	self.changed = true
	self.old_tmx, self.old_tmy = -1,-1
	self.old_turn = -1
end

--- Set the tooltip text
function _M:set(str, ...)
	self.text = str:format(...):splitLines(self.max, self.font)
	self.w, self.h = 0, 0
	for i, l in ipairs(self.text) do
		local w, h = self.font:size(l)
		if w > self.w then self.w = w end
		self.h = self.h + self.font_h
	end
	self.w = math.min(self.w, self.max) + 8
	self.h = self.h + 8
	self.changed = true
end

function _M:drawWBorder(s, x, y, w)
	for i = x, x + w do
		s:merge(tiles:get(nil, 0,0,0, 0,0,0, "border_8.png"), i, y)
	end
end

function _M:erase()
	self.surface = nil
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

	local i = 1
	local y = 0
	local r, g, b = self.color[1], self.color[2], self.color[3], nil
	for ii, l in ipairs(self.text) do
		if self.text[i] == "---" then
			self:drawWBorder(self.surface, 4, 4 + y + 0.5 * self.font_h, self.w - 8)
			i = i + 1
			y = y + self.font_h
		else
			r, g, b = self.surface:drawColorStringBlended(self.font, self.text[i], 4, 4 + y, self.color[1], self.color[2], self.color[3])
			i = i + 1
			y = y + self.font_h
		end
	end
	self.texture = self.surface:glTexture()
end

function _M:toScreen(x, y)
	if self.surface then
		self.surface:toScreenWithTexture(self.texture, x, y)
	end
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

	if self.old_tmx ~= tmx or self.old_tmy ~= tmy or (game.paused and self.old_turn ~= game.turn) then
		self.old_tmx, self.old_tmy = tmx, tmy
		self.old_turn = game.turn
		local tt = {}
		local seen = game.level.map.seens(tmx, tmy)
		local remember = game.level.map.remembers(tmx, tmy)
		tt[#tt+1] = seen and game.level.map:checkEntity(tmx, tmy, Map.PROJECTILE, "tooltip", game.level.map.actor_player) or nil
		tt[#tt+1] = seen and game.level.map:checkEntity(tmx, tmy, Map.ACTOR, "tooltip", game.level.map.actor_player) or nil
		tt[#tt+1] = seen and game.level.map:checkEntity(tmx, tmy, Map.OBJECT, "tooltip", game.level.map.actor_player) or nil
		tt[#tt+1] = seen and game.level.map:checkEntity(tmx, tmy, Map.TRAP, "tooltip", game.level.map.actor_player) or nil
		tt[#tt+1] = remember and game.level.map:checkEntity(tmx, tmy, Map.TERRAIN, "tooltip", game.level.map.actor_player) or nil
		if #tt > 0 then
			self:set("%s", table.concat(tt, "\n---\n"))
			self:display()
		else
			self:erase()
		end
	end

	if self.surface then
		mx = mx - self.w / 2 + game.level.map.tile_w / 2
		my = my - self.h
		if mx < 0 then mx = 0 end
		if my < 0 then my = 0 end
		if mx > game.w - self.w then mx = game.w - self.w end
		if my > game.h - self.h then my = game.h - self.h end
		self.surface:toScreenWithTexture(self.texture, mx, my)
	end
end
