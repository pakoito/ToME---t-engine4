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

local Heightmap = require "engine.Heightmap"

return function(gen, id)
	local w = rng.range(5, 12)
	local h = rng.range(5, 12)
	return { name="rocky_snowy_trees"..w.."x"..h, w=w, h=h, generator = function(self, x, y, is_lit)
		-- make the fractal heightmap
		local hm = Heightmap.new(self.w, self.h, 2, {middle=Heightmap.min, up_left=Heightmap.max, down_left=Heightmap.max, up_right=Heightmap.max, down_right=Heightmap.max})
		hm:generate()

		for i = 1, self.w do
			for j = 1, self.h do
				if hm.hmap[i][j] >= Heightmap.max * 5.4 / 6 then
					gen.map(i-1+x, j-1+y, Map.TERRAIN, gen:resolve('#'))
				elseif hm.hmap[i][j] >= Heightmap.max * 4.3 / 6 then
					gen.map(i-1+x, j-1+y, Map.TERRAIN, gen:resolve('T'))
				else
					gen.map.room_map[i-1+x][j-1+y].room = id
					gen.map(i-1+x, j-1+y, Map.TERRAIN, gen:resolve('.'))
				end
				if is_lit then gen.map.lites(i-1+x, j-1+y, true) end
			end
		end
	end}
end
