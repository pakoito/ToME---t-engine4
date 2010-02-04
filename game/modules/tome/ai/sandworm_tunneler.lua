local Object = require "engine.Object"

-- Ok some explanation, we make a new *OBJECT* because objects can have energy and act
-- it stores the current terrain in "old_feat" and restores it when it expires
-- We CAN set an object as a terrain because they are all entities
local sandbase = Object.new{
	name = "unstable sand tunnel", image = "terrain/sand.png",
	display = '.', color={r=203,g=189,b=72},
	canAct = function() return true end,
	act = function(self)
		self:useEnergy()
		self.temporary = self.temporary - 1
		if self.temporary <= 0 then
			game.level.map(self.x, self.y, Map.TERRAIN, self.old_feat)
			game:removeEntity(self)
		end
	end
}

-- Very special AI for sandworm tunnelers in the sandworm lair
-- Does not care about a target, simple crawl toward a level spot and when there, go for the next
newAI("sandworm_tunneler", function(self)
	-- Get a spot
	if not self.ai_state.spot_x then
		local s = rng.table(game.level.spots)
		self.ai_state.spot_x = s.x
		self.ai_state.spot_y = s.y
	end

	-- Move toward it, digging your way to it
	local l = line.new(self.x, self.y, self.ai_state.spot_x, self.ai_state.spot_y)
	local lx, ly = l()
	if not lx then
		self.ai_state.spot_x = nil
		self.ai_state.spot_y = nil
		self:useEnergy()
	else
		local feat = game.level.map(lx, ly, engine.Map.TERRAIN)
		if feat:check("block_move") then
			local sand = sandbase:clone()
			sand.old_feat = feat
			sand.temporary = 10
			sand.x = lx
			sand.y = ly

			game:addEntity(sand)
			game.level.map(lx, ly, engine.Map.TERRAIN, sand)
		end

		self:move(lx, ly)
	end
end)
