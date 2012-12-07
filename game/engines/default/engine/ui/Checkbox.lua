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
local Focusable = require "engine.ui.Focusable"

--- A generic UI textbox
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.title = assert(t.title, "no checkbox title")
	self.text = t.text or ""
	self.checked = t.default
	self.fct = t.fct or function() end
	self.on_change = t.on_change

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self.check = self:getUITexture("ui/checkbox.png")
	self.tick = self:getUITexture("ui/checkbox-ok.png")

	-- Draw UI
	self.title_w, self.title_h = self.font:size(self.title)
	self.w, self.h = self.title_w + self.check.w, math.max(self.font_h, self.check.h)

	local s = core.display.newSurface(self.title_w, self.title_h)
	s:drawColorStringBlended(self.font, self.title, 0, 0, 255, 255, 255, true)
	self.tex = {s:glTexture()}

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		if event == "button" then
			self:select()
		end
	end)
	self.key:addBind("ACCEPT", function() self.fct(self.checked) end)
	self.key:addCommands{
		_SPACE = function() self:select() end,
	}
end

function _M:select()
	self.checked = not self.checked
	self:sound("button")
	if self.on_change then self.on_change(self.checked) end
end

function _M:display(x, y, nb_keyframes)
	if self.text_shadow then self.tex[1]:toScreenFull(x+1, y+1 + (self.h - self.title_h) / 2, self.title_w, self.title_h, self.tex[2], self.tex[3], 0, 0, 0, self.text_shadow) end
	self.tex[1]:toScreenFull(x, y + (self.h - self.title_h) / 2, self.title_w, self.title_h, self.tex[2], self.tex[3])
	if self.focused then
		self.check.t:toScreenFull(x + self.title_w, y, self.check.w, self.check.h, self.check.tw, self.check.th)
	else
		self.check.t:toScreenFull(x + self.title_w, y, self.check.w, self.check.h, self.check.tw, self.check.th)
		if self.focus_decay then
--			self.check.t:toScreenFull(x + self.title_w, y, self.check.w, self.check.h, self.check.tw, self.check.th)
			self.focus_decay = self.focus_decay - nb_keyframes
			if self.focus_decay <= 0 then self.focus_decay = nil end
		end
	end
	if self.checked then
		self.tick.t:toScreenFull(x + self.title_w, y, self.tick.w, self.tick.h, self.tick.tw, self.tick.th)
	end
end
