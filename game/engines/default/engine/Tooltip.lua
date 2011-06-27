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
local Base = require "engine.ui.Base"
local TextzoneList = require "engine.ui.TextzoneList"
local Map = require "engine.Map"
local Tiles = require "engine.Tiles"

--- A generic tooltip
module(..., package.seeall, class.inherit(Base))

tiles = Tiles.new(16, 16)

function _M:init(fontname, fontsize, color, bgcolor, max)
	self.max = max or 300
	self.ui = "simple"
	self.font = {fontname or "/data/font/Vera.ttf", fontsize or 12}

	local conf = self.ui_conf[self.ui]
	self.frame = self.frame or {
		b7 = "ui/dialogframe_7.png",
		b9 = "ui/dialogframe_9.png",
		b1 = "ui/dialogframe_1.png",
		b3 = "ui/dialogframe_3.png",
		b4 = "ui/dialogframe_4.png",
		b6 = "ui/dialogframe_6.png",
		b8 = "ui/dialogframe_8.png",
		b2 = "ui/dialogframe_2.png",
		b5 = "ui/dialogframe_5.png",
		shadow = conf.frame_shadow,
		a = conf.frame_alpha or 1,
	}
	self.frame.a = 0.85
	self.frame.ox1 = self.frame.ox1 or conf.frame_ox1
	self.frame.ox2 = self.frame.ox2 or conf.frame_ox2
	self.frame.oy1 = self.frame.oy1 or conf.frame_oy1
	self.frame.oy2 = self.frame.oy2 or conf.frame_oy2

	self.default_ui = { TextzoneList.new{weakstore=true, width=self.max, height=500, variable_height=true, font=self.font, ui=self.ui} }

	self.uis = {}
	self.w = self.max + (self.frame.ox2 - self.frame.ox1) + 10
	self.h = 200
	Base.init(self, {})
end

function _M:generate()
	self.frame.w = self.w
	self.frame.h = self.h

	self.b7 = self:getUITexture(self.frame.b7)
	self.b9 = self:getUITexture(self.frame.b9)
	self.b1 = self:getUITexture(self.frame.b1)
	self.b3 = self:getUITexture(self.frame.b3)
	self.b8 = self:getUITexture(self.frame.b8)
	self.b4 = self:getUITexture(self.frame.b4)
	self.b2 = self:getUITexture(self.frame.b2)
	self.b6 = self:getUITexture(self.frame.b6)
	self.b5 = self:getUITexture(self.frame.b5)
end

--- Set the tooltip text
function _M:set(str, ...)
	if type(str) == "string" then str = str:format(...):toTString() end

	if str.is_tstring then
		self:erase()
		self.default_ui[1]:switchItem(str, str)
		self.empty = str:isEmpty()
	else
		if self.uids == self.default_ui then self.uids = {} end
		self.uids[#self.uids+1] = str
		self.empty = false
	end

	local uih = 0
	for i = 1, #self.uis do uih = uih + self.uis[i].h end
	self.h = uih + (self.frame.oy2 - self.frame.oy1) + 10
	self.frame.h = self.h
end

function _M:erase()
	self.uis = self.default_ui
	self.default_ui[1].list = nil
	self.empty = true
end

function _M:display() end

function _M:drawFrame(x, y, r, g, b, a)
	x = x + self.frame.ox1
	y = y + self.frame.oy1

	-- Corners
	self.b7.t:toScreenFull(x, y, self.b7.w, self.b7.h, self.b7.tw, self.b7.th, r, g, b, a)
	self.b1.t:toScreenFull(x, y + self.frame.h - self.b1.h, self.b1.w, self.b1.h, self.b1.tw, self.b1.th, r, g, b, a)
	self.b9.t:toScreenFull(x + self.frame.w - self.b9.w, y, self.b9.w, self.b9.h, self.b9.tw, self.b9.th, r, g, b, a)
	self.b3.t:toScreenFull(x + self.frame.w - self.b3.w, y + self.frame.h - self.b3.h, self.b3.w, self.b3.h, self.b3.tw, self.b3.th, r, g, b, a)

	-- Sides
	self.b8.t:toScreenFull(x + self.b7.w, y, self.frame.w - self.b7.w - self.b9.w, self.b8.h, self.b8.tw, self.b8.th, r, g, b, a)
	self.b2.t:toScreenFull(x + self.b7.w, y + self.frame.h - self.b3.h, self.frame.w - self.b7.w - self.b9.w, self.b2.h, self.b2.tw, self.b2.th, r, g, b, a)
	self.b4.t:toScreenFull(x, y + self.b7.h, self.b4.w, self.frame.h - self.b7.h - self.b1.h, self.b4.tw, self.b4.th, r, g, b, a)
	self.b6.t:toScreenFull(x + self.frame.w - self.b9.w, y + self.b7.h, self.b6.w, self.frame.h - self.b7.h - self.b1.h, self.b6.tw, self.b6.th, r, g, b, a)

	-- Body
	self.b5.t:toScreenFull(x + self.b7.w, y + self.b7.h, self.frame.w - self.b7.w - self.b3.w , self.frame.h - self.b7.h - self.b3.h, self.b6.tw, self.b6.th, r, g, b, a)
end

function _M:toScreen(x, y, nb_keyframes)
	local zoom = 1

	-- We translate and scale opengl matrix to make the popup effect easily
	local ox, oy = x, y
	local hw, hh = math.floor(self.w / 2), math.floor(self.h / 2)
	local tx, ty = x + hw, y + hh
	x, y = -hw, -hh
	core.display.glTranslate(tx, ty, 0)
	if zoom < 1 then core.display.glScale(zoom, zoom, zoom) end

	-- Draw the frame and shadow
	self:drawFrame(x, y, 1, 1, 1, self.frame.a)

	-- UI elements
	local uih = 0
	for i = 1, #self.uis do
		local ui = self.uis[i]
		ui:display(x + 5, y + 5 + uih, nb_keyframes, ox + 5, oy + 5 + uih)
		uih = uih + ui.h
	end

	-- Restiore normal opengl matrix
	if zoom < 1 then core.display.glScale() end
	core.display.glTranslate(-tx, -ty, 0)
end

--- Displays the tooltip at the given map coordinates
-- @param tmx the map coordinate to get tooltip from
-- @param tmy the map coordinate to get tooltip from
-- @param mx the screen coordinate to display at, if nil it will be computed from tmx
-- @param my the screen coordinate to display at, if nil it will be computed from tmy
-- @param text a text to display, if nil it will interrogate the map under the mouse using the "tooltip" property
function _M:displayAtMap(tmx, tmy, mx, my, text)
	if not mx then
		mx, my = game.level.map:getTileToScreen(tmx, tmy)
	end

	if text then
		if text ~= self.old_text then
			if type(text) == "string" then
				self:set("%s", text)
			else
				self:set(text)
			end
			self:display()
			self.old_text = text
		end
	else
		if self.old_tmx ~= tmx or self.old_tmy ~= tmy or (game.paused and self.old_turn ~= game.turn) then
			self.old_text = ""
			self.old_tmx, self.old_tmy = tmx, tmy
			self.old_turn = game.turn
			local tt = {}
			local ts = self:getTooltipAtMap(tmx, tmy, mx, my)
			if ts then
				self:set(ts)
				self:display()
			else
				self:erase()
			end
		end
	end

	if not self.empty then
--		mx = mx - self.w / 2 + game.level.map.tile_w / 2
--		my = my - self.h
		if mx < 0 then mx = 0 end
		if my < 0 then my = 0 end
		if mx > game.w - self.w then mx = game.w - self.w end
		if my > game.h - self.h then my = game.h - self.h end
		self.last_display_x = mx
		self.last_display_y = my
		self:toScreen(mx, my)
	end
end

--- Gets the tooltips at the given map coord
-- This method can/should be overloaded by a module to provide custom tooltips
function _M:getTooltipAtMap(tmx, tmy, mx, my)
	local tt = {}
	local seen = game.level.map.seens(tmx, tmy)
	local remember = game.level.map.remembers(tmx, tmy)
	tt[#tt+1] = seen and game.level.map:checkEntity(tmx, tmy, Map.PROJECTILE, "tooltip", game.level.map.actor_player) or nil
	tt[#tt+1] = seen and game.level.map:checkEntity(tmx, tmy, Map.ACTOR, "tooltip", game.level.map.actor_player) or nil
	tt[#tt+1] = (seen or remember) and game.level.map:checkEntity(tmx, tmy, Map.OBJECT, "tooltip", game.level.map.actor_player) or nil
	tt[#tt+1] = (seen or remember) and game.level.map:checkEntity(tmx, tmy, Map.TRAP, "tooltip", game.level.map.actor_player) or nil
	tt[#tt+1] = (seen or remember) and game.level.map:checkEntity(tmx, tmy, Map.TERRAIN, "tooltip", game.level.map.actor_player) or nil
	if #tt > 0 then
		local ts = tstring{}
		for i = 1, #tt do
			ts:merge(tt[i]:toTString())
			if i < #tt then ts:add(true, "---", true) end
		end
		return ts
	end
	return nil
end
