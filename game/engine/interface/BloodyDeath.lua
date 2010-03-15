require "engine.class"

--- Interface to add a bloodyDeath() method to actors
-- When this method is called, the floor or walls around the late actor is covered in blood
module(..., package.seeall, class.make)

--- Makes the bloody death happen
function _M:bloodyDeath()
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
			game.level.map(x, y, engine.Map.TERRAIN, game.level.map(x, y, engine.Map.TERRAIN):clone{color_r=color[1],color_g=color[2],color_b=color[3]})
		end
	end
end
