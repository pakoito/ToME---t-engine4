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

return function(gen, id, lev, old_lev)
	local w = rng.range(15, 15)
	local h = rng.range(15, 15)
	return { name="maze"..w.."x"..h, w=w, h=h, generator = function(self, x, y, is_lit)
		local map = engine.Map.new(w, h)
		local Maze = require("engine.generator.map.Maze")
		local maze = Maze.new(gen.zone, map, gen.grid_list, gen.data)
		maze:generate(lev, old_lev)
		gen.map:import(map, x, y)
		-- Make it a room, and make it special so that we do not tunnel through
		for i = x, x + w - 1 do for j = y, y + h - 1 do
			gen.map.room_map[i][j].special = true
			gen.map.room_map[i][j].room = id
		end end

		-- Mark the outer walls as pierceable
		for i = x, x + w - 1 do
			gen.map.room_map[i][y].special = false
			gen.map.room_map[i][y].room = nil
			gen.map.room_map[i][y].can_open = true
			gen.map.room_map[i][y+h-1].special = false
			gen.map.room_map[i][y+h-1].room = nil
			gen.map.room_map[i][y+h-1].can_open = true
		end
		for j = y, y + h - 1 do
			gen.map.room_map[x][j].special = false
			gen.map.room_map[x][j].room = nil
			gen.map.room_map[x][j].can_open = true
			gen.map.room_map[x+w-1][j].special = false
			gen.map.room_map[x+w-1][j].room = nil
			gen.map.room_map[x+w-1][j].can_open = true
		end
	end}
end
