-- ToME - Tales of Maj'Eyal
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
require "mod.class.Grid"
local Map = require "engine.Map"
local Quadratic = require "engine.Quadratic"

module(..., package.seeall, class.inherit(mod.class.Grid))

function _M:init(t, no_default)
	t.sphere_map = t.sphere_map or "stars/eyal.png"
	t.sphere_size = t.sphere_size or 1
	t.x_rot = t.x_rot or 0
	t.y_rot = t.y_rot or 0

	mod.class.Grid.init(self, t, no_default)

	self.world_sphere = Quadratic.new()

	self.sphere_size = self.sphere_size * Map.tile_w
end

function _M:defineDisplayCallback()
	if not self._mo then return end

	local tex = Map.tiles:get('', 0, 0, 0, 0, 0, 0, self.sphere_map)

	self._mo:displayCallback(function(x, y, w, h, zoom, on_map, tlx, tly)
		if not game.level then return end
		local rot = (game.level.data.frames % self.rot_speed) * 360 / self.rot_speed

		core.display.glDepthTest(true)
		core.display.glMatrix(true)
		core.display.glTranslate(x + w / 2, y + h / 2, 0)
		core.display.glRotate(self.x_rot, 0, 1, 0)
		core.display.glRotate(self.y_rot, 1, 0, 0)
		core.display.glRotate(rot, 0, 0, 1)
		core.display.glColor(1, 1, 1, 1)

		tex:bind(0)
		self.world_sphere.q:sphere(self.sphere_size)

		core.display.glMatrix(false)
		core.display.glDepthTest(false)

		return true
	end)
end
