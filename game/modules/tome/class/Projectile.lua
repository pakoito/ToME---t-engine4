-- ToME - Tales of Maj'Eyal
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
require "engine.Projectile"

module(..., package.seeall, class.inherit(engine.Projectile))

function _M:init(t, no_default)
	engine.Projectile.init(self, t, no_default)
end

--- Moves a projectile on the map
-- We override it to allow for movement animations
function _M:move(x, y, force)
	local ox, oy = self.x, self.y

	local moved = engine.Projectile.move(self, x, y, force)
	if moved and not force and ox and oy and (ox ~= self.x or oy ~= self.y) and config.settings.tome.smooth_move > 0 then
		self:setMoveAnim(ox, oy, config.settings.tome.smooth_move)
	end

	return moved
end
