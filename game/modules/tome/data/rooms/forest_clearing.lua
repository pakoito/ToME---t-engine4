local Heightmap = require "engine.Heightmap"

return function(gen, id)
	local w = rng.range(5, 12)
	local h = rng.range(5, 12)
	return { name="forest_clearing"..w.."x"..h, w=w, h=h, generator = function(self, x, y, is_lit)
		-- make the fractal heightmap
		local hm = Heightmap.new(self.w, self.h, 2, {middle=Heightmap.min, up_left=Heightmap.max, down_left=Heightmap.max, up_right=Heightmap.max, down_right=Heightmap.max})
		hm:generate()

		for i = 1, self.w do
			for j = 1, self.h do
				if hm.hmap[i][j] >= Heightmap.max * 5 / 6 then
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
