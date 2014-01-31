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
local WebView = require "engine.ui.WebView"

--- A generic tooltip
module(..., package.seeall, class.inherit(Base))

tooltip_bound_x1 = function() return 0 end
tooltip_bound_x2 = function() return game.w end
tooltip_bound_y1 = function() return 0 end
tooltip_bound_y2 = function() return game.h end

function _M:init(width, height, url)
	self.w = width
	self.h = height
	self.view = WebView.new{width = self.w - 6, height = self.h - 6, url=url }
	Base.init(self, {})
end

function _M:generate()
	self.frame = Base:makeFrame("ui/tooltip/", self.w + 6, self.h + 6)
end

function _M:display() end

function _M:toScreen(x, y, nb_keyframes)
	self.last_display_x = x
	self.last_display_y = y

	nb_keyframes = nb_keyframes or 0
	-- Save current matrix and load coords to default values
	core.display.glPush()
	core.display.glIdentity()
	
	-- Draw the frame and shadow
	self:drawFrame(self.frame, x, y, 0, 0, 0, 0.3, self.w, self.h) -- shadow
	self:drawFrame(self.frame, x, y, 1, 1, 1, 0.75) -- unlocked frame
	
	self.view:display(x + 8, y + 8, nb_keyframes, x + 8, y + 8)
	
	-- Restore saved opengl matrix
	core.display.glPop()
end
