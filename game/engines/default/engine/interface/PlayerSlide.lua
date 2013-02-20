-- TE4 - T-Engine 4
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
local Map = require "engine.Map"

--- Makes the player "slide" along walls when possible
-- Simply call x, y = self:tryPlayerSlide(x, y, force) in your player's move() method
module(..., package.seeall, class.make)

function _M:tryPlayerSlide(x, y, force)
	-- Try to slide along walls if possible
	if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move", self, false) and not force then
		local zig_zag = util.dirZigZag(self.move_dir, self.x, self.y)
		local slide_dir = zig_zag and zig_zag[self.zig_zag] or util.dirSides(self.move_dir, self.x, self.y)
		if slide_dir then
			if type(slide_dir) == "table" and slide_dir.left and slide_dir.right then
				tx1, ty1 = util.coordAddDir(self.x, self.y, slide_dir.left)
				tx2, ty2 = util.coordAddDir(self.x, self.y, slide_dir.right)
				if not game.level.map:checkEntity(tx1, ty1, Map.TERRAIN, "block_move", self, false) and game.level.map:checkEntity(tx2, ty2, Map.TERRAIN, "block_move", self, false) then
					self.zig_zag = util.dirNextZigZag(slide_dir.left, self.x, self.y)
					return tx1, ty1
				elseif game.level.map:checkEntity(tx1, ty1, Map.TERRAIN, "block_move", self, false) and not game.level.map:checkEntity(tx2, ty2, Map.TERRAIN, "block_move", self, false) then
					self.zig_zag = util.dirNextZigZag(slide_dir.right, self.x, self.y)
					return tx2, ty2
				end
			else
				slide_dir = type(slide_dir) == "table" and (slide_dir.right or slide_dir.left) or slide_dir
				tx, ty = util.coordAddDir(self.x, self.y, slide_dir)
				if not game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move", self, false) then
					self.zig_zag = util.dirNextZigZag(slide_dir, self.x, self.y)
					return tx, ty
				end
			end
		end


--[[
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
--]]
	end
	return nil
end
