local Object = require "engine.Object"
local DamageType = require "engine.DamageType"

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
			self:project({type="hit"}, lx, ly, DamageType.DIG, 1)
		end
		self:move(lx, ly)
	end
end)
