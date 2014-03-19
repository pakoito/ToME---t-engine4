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
local Tab = require "engine.ui.Tab"
local Separator = require "engine.ui.Separator"
local UIGroup = require "engine.ui.UIGroup"

--- A tab container
module(..., package.seeall, class.inherit(Base, Focusable, UIGroup))

function _M:init(t)
	self.tabs = assert(t.tabs, "no tab tabs")
	self.on_change = assert(t.on_change, "no on_change")
	self.force_width = t.width

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self.uis = {}

	local cx = 0
	for i, tdef in ipairs(self.tabs) do
		local kind = tdef.kind
		local tab = Tab.new{title=tdef.title, on_change=function() self:select(kind) end}
		tab.mouse.delegate_offset_x = cx
		tab.mouse.delegate_offset_y = 0
		self.uis[#self.uis+1] = {x=cx, y=0, ui=tab}
		cx = cx + tab.w
		self.h = math.max(tab.h, self.h or 0)
	end
	self.w = self.force_width or cx

	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		self:mouseEvent(button, x, y, xrel, yrel, bx, by, event)
	end)

	self:select(self.tabs[1].kind)
end

function _M:mouseEvent(button, x, y, xrel, yrel, bx, by, event)
	-- Look for focus
	for i = 1, #self.uis do
		local ui = self.uis[i]
		if ui.ui.can_focus and bx >= ui.x and bx <= ui.x + ui.ui.w and by >= ui.y and by <= ui.y + ui.ui.h then
			self:setInnerFocus(i)

			-- Pass the event
			ui.ui.mouse:delegate(button, bx, by, xrel, yrel, bx, by, event)
			return
		end
	end
	self:no_focus()
end

function _M:select(kind)
	for i, ui in ipairs(self.uis) do
		if self.tabs[i].kind == kind then ui.ui.selected = true
		else ui.ui.selected = false
		end
	end

	self.on_change(kind)
end

function _M:display(x, y, nb_keyframes, ox, oy)
	self._last_x, _last_y, self._last_ox, self._last_oy = x, y, ox, oy

	-- UI elements
	for i = 1, #self.uis do
		local ui = self.uis[i]
		if not ui.hidden then ui.ui:display(x + ui.x, y + ui.y, nb_keyframes, ox + ui.x, oy + ui.y) end
	end
end
