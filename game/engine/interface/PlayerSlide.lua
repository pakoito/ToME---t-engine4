require "engine.class"

--- Makes the player "slide" along walls when possible
-- Simply call x, y = self:tryPlayerSlide(x, y, force) in your player's move() method
module(..., package.seeall, class.make)

function _M:tryPlayerSlide(x, y, force)
	-- Try to slide along walls if possible
	if game.level.map:checkAllEntities(x, y, "block_move", self, false) and not force then
		local dir = util.getDir(x, y, self.x, self.y)
		local ldir, rdir = dir_sides[dir].left, dir_sides[dir].right
		local lx, ly = util.coordAddDir(self.x, self.y, ldir)
		local rx, ry = util.coordAddDir(self.x, self.y, rdir)
		-- Slide left
		if not game.level.map:checkAllEntities(lx, ly, "block_move", self, false) and game.level.map:checkAllEntities(rx, ry, "block_move", self, false) then
			x, y = lx, ly
		-- Slide right
		elseif game.level.map:checkAllEntities(lx, ly, "block_move", self, false) and not game.level.map:checkAllEntities(rx, ry, "block_move", self, false) then
			x, y = rx, ry
		end
	end
	return x, y
end
