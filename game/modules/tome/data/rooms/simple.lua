--[[
return function(self, gen)
	return { name=self.name, w = rng.range(6, 15), h = rng.range(6, 15), generator = function(self, gen, x, y, id)
		for i = 1, self.w do
			for j = 1, self.h do
				gen.room_map[i-1+x][j-1+y].room = id
				if i == 1 or i == self.w or j == 1 or j == self.h then
					gen.room_map[i-1+x][j-1+y].can_open = true
					gen.map(i-1+x, j-1+y, Map.TERRAIN, gen.grid_list[gen:resolve('#')])
				else
					gen.map(i-1+x, j-1+y, Map.TERRAIN, gen.grid_list[gen:resolve('.')])
				end
			end
		end
	end}
end
-- ]]
-- [=[
return {
[[#!!!!!!!!!!#]],
[[!..........!]],
[[!..........!]],
[[!..........!]],
[[!..........!]],
[[!..........!]],
[[#!!!!!!!!!!#]],
}
-- ]=]
