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

--- A generic UI button
module(..., package.seeall, class.inherit(Base, Focusable))

frame_ox1 = -5
frame_ox2 = 5
frame_oy1 = -5
frame_oy2 = 5

function _M:init(t)
	self.text = assert(t.text, "no button text")
	self.fct = assert(t.fct, "no button fct")
	self.on_select = t.on_select
	self.force_w = t.width
	if t.can_focus ~= nil then self.can_focus = t.can_focus end
	if t.can_focus_mouse ~= nil then self.can_focus_mouse = t.can_focus_mouse end
	self.alpha_unfocus = t.alpha_unfocus or 1

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	-- Draw UI
	self.font:setStyle("bold")
	local w, h = self.font:size(self.text)
	self.iw, self.ih = w, h
	if self.force_w then w = self.force_w end
	self.w, self.h = w - frame_ox1 + frame_ox2, h - frame_oy1 + frame_oy2

	local s = core.display.newSurface(w, h)
	s:drawColorStringBlended(self.font, self.text, 0, 0, 255, 255, 255, true)
	self.tex = {s:glTexture()}
	self.font:setStyle("normal")

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w+6, self.h+6, function(button, x, y, xrel, yrel, bx, by, event)
		if self.hide then return end
		if self.on_select then self.on_select() end
		if button == "left" and event == "button" then self:sound("button") self.fct() end
	end)
	self.key:addBind("ACCEPT", function() self:sound("button") self.fct() end)

	self.rw, self.rh = w, h
	self.frame = self:makeFrame("ui/button", self.w, self.h)
	self.frame_sel = self:makeFrame("ui/button_sel", self.w, self.h)

	-- Add a bit of padding
	self.w = self.w + 6
	self.h = self.h + 6
end

function _M:display(x, y, nb_keyframes, ox, oy)
	self.last_display_x = ox
	self.last_display_y = oy

	if self.hide then return end

	x = x + 3
	y = y + 3
	ox = ox + 3
	oy = oy + 3
	local mx, my, button = core.mouse.get()
	if self.focused then
		if button == 1 and mx > ox and mx < ox+self.w and my > oy and my < oy+self.h then
			self:drawFrame(self.frame, x, y, 0, 1, 0, 1)
		elseif self.glow then
			local v = self.glow + (1 - self.glow) * (1 + math.cos(core.game.getTime() / 300)) / 2
			self:drawFrame(self.frame, x, y, v*0.8, v, 0, 1)
		else
			self:drawFrame(self.frame_sel, x, y)
		end
		if self.text_shadow then self.tex[1]:toScreenFull(x-frame_ox1+1, y-frame_oy1+1, self.rw, self.rh, self.tex[2], self.tex[3], 0, 0, 0, self.text_shadow) end
		self.tex[1]:toScreenFull(x-frame_ox1, y-frame_oy1, self.rw, self.rh, self.tex[2], self.tex[3])
	else
		if self.glow then
			local v = self.glow + (1 - self.glow) * (1 + math.cos(core.game.getTime() / 300)) / 2
			self:drawFrame(self.frame, x, y, v*0.8, v, 0, self.alpha_unfocus)
		else
			self:drawFrame(self.frame, x, y, 1, 1, 1, self.alpha_unfocus)
		end

		if self.focus_decay and not self.glow then
			self:drawFrame(self.frame_sel, x, y, 1, 1, 1, self.alpha_unfocus * self.focus_decay / self.focus_decay_max_d)
			self.focus_decay = self.focus_decay - nb_keyframes
			if self.focus_decay <= 0 then self.focus_decay = nil end
		end
		if self.text_shadow then self.tex[1]:toScreenFull(x-frame_ox1+1, y-frame_oy1+1, self.rw, self.rh, self.tex[2], self.tex[3], 0, 0, 0, self.alpha_unfocus * self.text_shadow) end
		self.tex[1]:toScreenFull(x-frame_ox1, y-frame_oy1, self.rw, self.rh, self.tex[2], self.tex[3], 1, 1, 1, self.alpha_unfocus)
	end
end
