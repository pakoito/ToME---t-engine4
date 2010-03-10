return function(gen, id)
	local w = 5
	local h = 5
	return { name="greater_vault"..w.."x"..h, w=w, h=h, generator = function(self, x, y, is_lit)
		for i = 1, self.w do
			for j = 1, self.h do
				if i == 1 or i == self.w or j == 1 or j == self.h then
					gen.map.room_map[i-1+x][j-1+y].can_open = true
					gen.map(i-1+x, j-1+y, Map.TERRAIN, gen.grid_list[gen:resolve('#')])
				else
					gen.map.room_map[i-1+x][j-1+y].room = id
					gen.map(i-1+x, j-1+y, Map.TERRAIN, gen.grid_list[gen:resolve('.')])

					-- Add money
					local e = gen.zone:makeEntity(gen.level, "object", {type="money"})
					if e then
						gen.zone:addEntity(gen.level, e, "object", i-1+x, j-1+y)
					end
					-- Add guardians
					if rng.percent(50) then
						e = gen.zone:makeEntity(gen.level, "actor")
						if e then
							gen.zone:addEntity(gen.level, e, "actor", i-1+x, j-1+y)
						end
					end
				end
				if is_lit then gen.map.lites(i-1+x, j-1+y, true) end
			end
		end
	end}
end
