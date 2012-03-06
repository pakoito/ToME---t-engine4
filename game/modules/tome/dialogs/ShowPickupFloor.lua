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
local Base = require "engine.dialogs.ShowPickupFloor"

module(..., package.seeall, class.inherit(Base))

function _M:init(...)
	Base.init(self, ...)

	self.key.any_key = function(sym)
		-- Control resets the tooltip
		if (sym == self.key._LCTRL or sym == self.key._RCTRL) and self.cur_item then self.cur_item.desc = nil self:select(self.cur_item) end
	end

	for i, item in ipairs(self.list) do item.desc = nil end

	self:select(self.list[1])
end

function _M:select(item)
	if item then
		self.cur_item = item
		if not item.desc or item.ctrl_state ~= core.key.modState("ctrl") then
			item.ctrl_state = core.key.modState("ctrl")
			item.desc = item.object:getDesc({do_color=true}, self.actor:getInven(item.object:wornInven()))
			self.c_desc:createItem(item, item.desc)
		end
		self.c_desc:switchItem(item, item.desc)
	end
end

function _M:updateTitle(title)
	Base.updateTitle(self, title)

	local green = colors.LIGHT_GREEN
	local red = colors.LIGHT_RED

	local enc, max = self.actor:getEncumbrance(), self.actor:getMaxEncumbrance()
	local v = math.min(enc, max) / max
	self.title_fill = self.iw * v
	self.title_fill_color = {
		r = util.lerp(green.r, red.r, v),
		g = util.lerp(green.g, red.g, v),
		b = util.lerp(green.b, red.b, v),
	}
end

function _M:drawFrame(x, y, r, g, b, a)
	Base.drawFrame(self, x, y, r, g, b, a)
	if r == 0 then return end -- Drawing the shadow
	if self.ui ~= "metal" then return end
	if not self.title_fill then return end

	core.display.drawQuad(x + self.frame.title_x, y + self.frame.title_y, self.title_fill, self.frame.title_h, self.title_fill_color.r, self.title_fill_color.g, self.title_fill_color.b, 60)
end
