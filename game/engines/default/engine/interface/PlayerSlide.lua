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
local Map = require "engine.Map"

--- Makes the player "slide" along walls when possible
-- Simply call x, y = self:tryPlayerSlide(x, y, force) in your player's move() method
module(..., package.seeall, class.make)

function _M:tryPlayerSlide(x, y, force)
	-- Try to slide along walls if possible
	if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move", self, false) and not force then
		local dir = util.getDir(x, y, self.x, self.y)
		local ldir, rdir = dir_sides[dir].left, dir_sides[dir].right
		local lx, ly = util.coordAddDir(self.x, self.y, ldir)
		local rx, ry = util.coordAddDir(self.x, self.y, rdir)
		-- Slide left
		if not game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_move", self, false) and game.level.map:checkEntity(rx, ry, Map.TERRAIN, "block_move", self, false) then
			x, y = lx, ly
		-- Slide right
		elseif game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_move", self, false) and not game.level.map:checkEntity(rx, ry, Map.TERRAIN, "block_move", self, false) then
			x, y = rx, ry
		end
	end
	return x, y
end
