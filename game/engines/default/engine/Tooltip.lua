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
    
	self.fontsize = fontsize
	self.font = core.display.newFont(fontname or "/data/font/DroidSans.ttf", fontsize or 12)

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
	if type(str) == "string" then str = ... and str:format(...):toTString() or str:toTString() end
	if type(str) == "number" then str = tostring(str):toTString() end

	local max_w = 0
	local max_str_w = self.add_map_str and (self.add_map_str:toTString()):maxWidth(self.font) or 0
	local uis = {}
	if not str.is_tstring then
		for i=1, #str do
		if type(str[i]) == "string" then
			str[i] = str[i]:toTString()
		end
			if str[i].is_tstring then
				max_str_w = math.max(str[i]:maxWidth(self.font) + 5, max_str_w)
		else
				max_w = math.max(str[i].w, max_w)
			end
		end
		
		max_str_w = math.min(max_str_w, self.max)
		max_w = math.max(max_w, max_str_w)

		local ts = tstring{}
		if self.add_map_str then ts:merge(self.add_map_str:toTString()) ts:add("---", true) end
		for i=1, #str do
			if str[i].is_tstring then
				if i > 1 then 
					if str[i - 1] and str[i - 1].is_tstring then 
						ts:add(true) 
					end 
					ts:add("---", true)
				end
				ts:merge(str[i]:toTString())
			else
				if i > 1 then
					if not str[i].suppress_line_break then
						ts:add(true, "---")
					end
					local tz = TextzoneList.new{weakstore=true, width=max_w, height=500, variable_height=true, font=self.font, ui=self.ui}
					tz:switchItem(ts, ts)
					uis[#uis + 1] = tz
				end
				uis[#uis + 1] = str[i]

				ts = tstring{}
			end
		end
		local tz = TextzoneList.new{weakstore=true, width=max_w, height=500, variable_height=true, font=self.font, ui=self.ui}
		tz:switchItem(ts, ts)
		uis[#uis + 1] = tz
		
		if self.uis == self.default_ui then self:erase() end
		self.uis = uis
		self.empty = false
	else
		self:erase()
		self.default_ui[1]:switchItem(str, str) 
		max_w = self.max
		self.empty = str:isEmpty()
	end

	local uih = 0
	for i = 1, #self.uis do uih = uih + self.uis[i].h end
    
	self.h = uih + self.frame.b2.h
	self.w = max_w + self.frame.b4.w
    
	self.frame.h = self.h
	self.frame.w = self.w
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
	local hw, hh = math.floor(self.w * 0.5), math.floor(self.h * 0.5)
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

	-- Restore normal opengl matrix
	core.display.glTranslate(-tx, -ty, 0)
end

--- Displays the tooltip at the given map coordinates
-- @param tmx the map coordinate to get tooltip from
-- @param tmy the map coordinate to get tooltip from
-- @param mx the screen coordinate to display at, if nil it will be computed from tmx
-- @param my the screen coordinate to display at, if nil it will be computed from tmy
-- @param text a text to display, if nil it will interrogate the map under the mouse using the "tooltip" property
-- @param force forces tooltip to refresh
function _M:displayAtMap(tmx, tmy, mx, my, text, force)
	if not mx then
		mx, my = game.level.map:getTileToScreen(tmx, tmy)
	end

	if text then
		if text ~= self.old_text then
			self:set(text)
			self:display()
			self.old_text = text
		end
	else
		if self.old_ttmx ~= tmx or self.old_ttmy ~= tmy or (game.paused and self.old_turn ~= game.turn) or force then
			self.old_text = ""
			self.old_ttmx, self.old_ttmy = tmx, tmy
			self.old_turn = game.turn
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
	local ctrl_state = core.key.modState("ctrl")
	
	local check = function(check_type)
		local to_add = game.level.map:checkEntity(tmx, tmy, check_type, "tooltip", game.level.map.actor_player)
		if to_add then 
			if type(to_add) == "string" then to_add = to_add:toTString() end
			tt[#tt+1] = to_add 
		end
	end
	
	if seen and not ctrl_state then
		check(Map.PROJECTILE)
		check(Map.ACTOR)
	end
	if seen or remember then
		local obj = check(Map.OBJECT)
		if not ctrl_state or not obj then
			check(Map.TRAP)
			check(Map.TERRAIN)
		end
	end
	
	if #tt > 0 then
		return tt
	end
	if self.add_map_str then return self.add_map_str:toTString() end
	return nil
end
