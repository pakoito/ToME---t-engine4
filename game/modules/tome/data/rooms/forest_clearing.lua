return function(gen, id)
	local w = rng.range(5, 12)
	local h = rng.range(5, 12)
	return { name="forest_clearing"..w.."x"..h, w=w, h=h, generator = function(self, x, y, is_lit)
		for i = 1, self.w do
			for j = 1, self.h do
				if i == 1 or i == self.w or j == 1 or j == self.h then
					gen.room_map[i-1+x][j-1+y].can_open = true
					gen.map(i-1+x, j-1+y, Map.TERRAIN, gen.grid_list[gen:resolve('#')])
				else
					gen.room_map[i-1+x][j-1+y].room = id
					gen.map(i-1+x, j-1+y, Map.TERRAIN, gen.grid_list[gen:resolve('.')])
				end
				if is_lit then gen.map.lites(i-1+x, j-1+y, true) end
			end
		end
	end}
end
