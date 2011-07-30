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
local Base = require "engine.dialogs.ShowStore"

module(..., package.seeall, class.inherit(Base))

function _M:init(...)
	Base.init(self, ...)

	-- Add tooltips
	self.on_select = function(item)
		if item.last_display_x and item.object then
			game:tooltipDisplayAtMap(item.last_display_x, item.last_display_y, item.object:getDesc({do_color=true}, game.player:getInven(item.object:wornInven())))
		end
	end
	self.key.any_key = function(sym)
		-- Control resets the tooltip
		if sym == self.key._LCTRL or sym == self.key._RCTRL then local i = self.cur_item self.cur_item = nil self:select(i) end
	end
end
