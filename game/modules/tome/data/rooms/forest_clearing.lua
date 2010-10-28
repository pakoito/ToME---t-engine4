-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
	local w = rng.range(6, 10)
	local h = rng.range(6, 10)
	return { name="forest_clearing"..w.."x"..h, w=w, h=h, generator = function(self, x, y, is_lit)
		-- make the fractal heightmap
		local hm = Heightmap.new(self.w, self.h, 2, {middle=Heightmap.min, up_left=Heightmap.max, down_left=Heightmap.max, up_right=Heightmap.max, down_right=Heightmap.max})
		hm:generate()

		local ispit = gen.data.rooms_config and gen.data.rooms_config.forest_clearing and rng.percent(gen.data.rooms_config.forest_clearing.pit_chance)
		if ispit then ispit = rng.table(gen.data.rooms_config.forest_clearing.filters) end

		for i = 1, self.w do
			for j = 1, self.h do
				if hm.hmap[i][j] >= Heightmap.max * 5 / 6 then
--					gen.map.room_map[i-1+x][j-1+y].can_open = true
					gen.map(i-1+x, j-1+y, Map.TERRAIN, gen:resolve('#'))
				else
					gen.map.room_map[i-1+x][j-1+y].room = id
					gen.map(i-1+x, j-1+y, Map.TERRAIN, gen:resolve('.'))

					if ispit then
						local e = gen.zone:makeEntity(gen.level, "actor", ispit, nil, true)
						if e then
							if e then gen:roomMapAddEntity(i-1+x, j-1+y, "actor", e) end
							gen.map.attrs(i-1+x, j-1+y, "no_decay", true)
						end
					end
				end
				if is_lit then gen.map.lites(i-1+x, j-1+y, true) end
			end
		end
	end}
end
