-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
local Particles = require "engine.Particles"
local Grid = require "mod.class.Grid"

module(..., package.seeall, class.inherit(Grid))

function _M:init(t, no_default)
	Grid.init(self, t, no_default)
end

--- Attach or remove a display callback
-- Defines particles to display
function _M:defineDisplayCallback()
	if not self._mo then return end

	self._mo:displayCallback(function(x, y, w, h, zoom, on_map)
		local glow = game.level.entrance_glow
		if glow and self.change_zone and not game.visited_zones[self.change_zone] then
			glow:checkDisplay()
			if glow.ps:isAlive() then glow.ps:toScreen(x + w / 2, y + h / 2, true, w / (game.level and game.level.map.tile_w or w))
			else self:removeParticles()
			end
		end

		return true
	end)
end
