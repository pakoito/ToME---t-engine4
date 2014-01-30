-- TE4 - T-Engine 4
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
local Focusable = require "engine.ui.Focusable"

--- A generic UI textbox
module(..., package.seeall, class.inherit(Base, Focusable))

frame_ox1 = -5
frame_ox2 = 5
frame_oy1 = -1
frame_oy2 = 1

function _M:init(t)
	self.title = assert(t.title, "no tab title")
	self.text = t.text or ""
	self.selected = t.default
	self.fct = t.fct
	self.on_change = t.on_change

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	-- Draw UI
	self.title_w, self.title_h = self.font:size(self.title)
	self.w, self.h = self.title_w - frame_ox1 + frame_ox2, self.title_h - frame_oy1 + frame_oy2

	local s = core.display.newSurface(self.title_w, self.title_h)
	s:drawColorStringBlended(self.font, self.title, 0, 0, 255, 255, 255, true)
	self.tex = {s:glTexture()}

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w+1, self.h+6, function(button, x, y, xrel, yrel, bx, by, event)
		if event == "button" then
			self:select()
		end
	end)

	self.rw, self.rh = self.title_w, self.title_h
	self.frame = self:makeFrame("ui/button", self.w, self.h)
--	self.frame.b2 = self:getUITexture("ui/border_hor_middle.png")

	self.frame_sel = self:makeFrame("ui/button_sel", self.w, self.h)

	self.key:addBind("ACCEPT", function()
		self:sound("button")
		self.fct(self.selected)
	end)
	self.key:addCommands{
		_SPACE = function() self:select() end,
	}

	self.w = self.w + 1
	self.h = self.h + 6
end

function _M:drawFrame(f, x, y, r, g, b, a)
	-- Sides
	f.b8.t:toScreenFull(x + f.b7.w, y, f.w - f.b7.w - f.b9.w + 1, f.b8.h, f.b8.tw, f.b8.th, r, g, b, a)
	f.b2.t:toScreenFull(x , y + f.h - 3, f.w , f.b2.h, f.b2.tw, f.b2.th, r, g, b, a)
	f.b4.t:toScreenFull(x, y + f.b7.h, f.b4.w, f.h - f.b7.h + 1, f.b4.tw, f.b4.th, r, g, b, a)
	f.b6.t:toScreenFull(x + f.w - f.b9.w, y + f.b7.h, f.b6.w, f.h - f.b7.h + 1, f.b6.tw, f.b6.th, r, g, b, a)

	-- Body
	f.b5.t:toScreenFull(x + f.b7.w, y + f.b7.h, f.w - f.b7.w - f.b9.w + 1, f.h - f.b7.h + 1, f.b6.tw, f.b6.th, r, g, b, a)

	-- Corners
	f.b7.t:toScreenFull(x, y, f.b7.w, f.b7.h, f.b7.tw, f.b7.th, r, g, b, a)
	f.b9.t:toScreenFull(x + f.w - f.b9.w, y, f.b9.w, f.b9.h, f.b9.tw, f.b9.th, r, g, b, a)
end

function _M:select()
	self.selected = true
	if self.on_change then self.on_change(self.selected) end
end

function _M:display(x, y, nb_keyframes)
	x = x + 3
	y = y + 4
	if self.selected then
		self:drawFrame(self.frame_sel, x, y)
	elseif not self.focused then
		self:drawFrame(self.frame, x, y, 1, 1, 1, 1)
		if self.focus_decay then
			self:drawFrame(self.frame_sel, x, y, 1, 0.5, 0.5, self.focus_decay / self.focus_decay_max_d)
			self.focus_decay = self.focus_decay - nb_keyframes
			if self.focus_decay <= 0 then self.focus_decay = nil end
		end
	else
		self:drawFrame(self.frame_sel, x, y, 1, 0.5, 0.5, 1)
	end
	if self.text_shadow then self.tex[1]:toScreenFull(x+1-frame_ox1, y+1-frame_oy1, self.rw, self.rh, self.tex[2], self.tex[3], 0, 0, 0, self.text_shadow) end
	self.tex[1]:toScreenFull(x-frame_ox1, y-frame_oy1, self.rw, self.rh, self.tex[2], self.tex[3])
end
