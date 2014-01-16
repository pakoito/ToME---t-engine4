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

--- Interface to add a bloodyDeath() method to actors
-- When this method is called, the floor or walls around the late actor is covered in blood
module(..., package.seeall, class.make)

--- Makes the bloody death happen
-- @param tint true if the color is applied as a tint, false if it changes the actual color
function _M:bloodyDeath(tint)
	if not self.has_blood then return end
	local color = {255,0,100}
	local done = 3
	if type(self.has_blood) == "table" then
		done = self.has_blood.nb or 3
		color = self.has_blood.color
	end
	for i = 1, done do
		local x, y = rng.range(self.x - 1, self.x + 1), rng.range(self.y - 1, self.y + 1)
		if game.level.map(x, y, engine.Map.TERRAIN) then
			-- Get the grid, clone it and alter its color
			if tint then
				game.level.map(x, y, engine.Map.TERRAIN, game.level.map(x, y, engine.Map.TERRAIN):clone{
					tint_r=color[1],tint_g=color[2],tint_b=color[3]
				})
			else
				game.level.map(x, y, engine.Map.TERRAIN, game.level.map(x, y, engine.Map.TERRAIN):clone{
					color_r=color[1],color_g=color[2],color_b=color[3]
				})
			end
		end
	end
end
