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
			gen.room_map[i][j].special = true
			gen.room_map[i][j].room = id
		end end

		-- Mark the outer walls are piercable
		for i = x, x + w - 1 do
			gen.room_map[i][y].special = false
			gen.room_map[i][y].room = nil
			gen.room_map[i][y].can_open = true
			gen.room_map[i][y+h-1].special = false
			gen.room_map[i][y+h-1].room = nil
			gen.room_map[i][y+h-1].can_open = true
		end
		for j = y, y + h - 1 do
			gen.room_map[x][j].special = false
			gen.room_map[x][j].room = nil
			gen.room_map[x][j].can_open = true
			gen.room_map[x+w-1][j].special = false
			gen.room_map[x+w-1][j].room = nil
			gen.room_map[x+w-1][j].can_open = true
		end
	end}
end
