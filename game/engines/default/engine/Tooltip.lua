-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

--- A generic tooltip
module(..., package.seeall, class.inherit(Base))

tooltip_bound_x1 = 0
tooltip_bound_x2 = function() return game.w end
tooltip_bound_y1 = 0
tooltip_bound_y2 = function() return game.h end

function _M:init(fontname, fontsize, color, bgcolor, max)
	self.max = max or 300
	self.ui = "simple"
	self.font = {fontname or "/data/font/DroidSans.ttf", fontsize or 12}
	self.default_ui = { TextzoneList.new{weakstore=true, width=self.max, height=500, variable_height=true, font=self.font, ui=self.ui} }

	self.uis = {}
	self.w = self.max + 10
	self.h = 200
	Base.init(self, {})
end

function _M:generate()
	self.frame = self:makeFrame("ui/tooltip/", self.w + 6, self.h + 6)
end

--- Set the tooltip text
function _M:set(str, ...)
	if type(str) == "string" then str = str:format(...):toTString() end
	if type(str) == "number" then str = tostring(str):toTString() end

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
	self.h = uih + 16
	self.frame.h = self.h
end

function _M:erase()
	self.uis = self.default_ui
	self.default_ui[1].list = nil
	self.empty = true
end

function _M:display() end

function _M:toScreen(x, y, nb_keyframes)
	-- We translate and scale opengl matrix to make the popup effect easily
	local ox, oy = math.floor(x), math.floor(y)
	x, y = ox, oy
	local hw, hh = math.floor(self.w / 2), math.floor(self.h / 2)
	local tx, ty = x + hw, y + hh
	x, y = -hw, -hh
	core.display.glTranslate(tx, ty, 0)

	-- Draw the frame and shadow
	self:drawFrame(self.frame, x+1, y+1, 0, 0, 0, 0.3)
	self:drawFrame(self.frame, x-3, y-3, 1, 1, 1, 0.75)

	-- UI elements
	local uih = 0
	for i = 1, #self.uis do
		local ui = self.uis[i]
		ui:display(x + 5, y + 5 + uih, nb_keyframes, ox + 5, oy + 5 + uih)
		uih = uih + ui.h
	end

	-- Restiore normal opengl matrix
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
		local x1, x2, y1, y2 = util.getval(self.tooltip_bound_x1), util.getval(self.tooltip_bound_x2), util.getval(self.tooltip_bound_y1), util.getval(self.tooltip_bound_y2)
		if mx < x1 then mx = x1 end
		if my < y1 then my = y1 end
		if mx > x2 - self.w then mx = x2 - self.w end
		if my > y2 - self.h then my = y2 - self.h end
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
