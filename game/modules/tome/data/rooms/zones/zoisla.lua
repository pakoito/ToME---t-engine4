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

return function(gen, id)
	local w = 4
	local h = 4
	return { name="zoisla"..w.."x"..h, w=w, h=h, generator = function(self, x, y, is_lit)
		local spots = {}
		for i = 1, self.w do
			for j = 1, self.h do
				gen.map.room_map[i-1+x][j-1+y].room = id
				gen.map(i-1+x, j-1+y, Map.TERRAIN, gen:resolve('near_portal'))
				spots[#spots+1] = {x=i-1+x, y=j-1+y}
			end
		end

		local s = rng.tableRemove(spots)
		gen.map(s.x, s.y, Map.TERRAIN, gen:resolve('portal'))
		print("Zoisla portal at", s.x, s.y)

		for i = 1, 3 do
			local s = rng.tableRemove(spots)
			local e = gen.zone:makeEntity(gen.level, "actor", {subtype="naga"}, nil, true)
			if e then gen:roomMapAddEntity(s.x, s.y, "actor", e) end
		end
	end}
end
