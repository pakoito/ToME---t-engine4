-- Defines a simple AI building blocks
-- Target nearest and move/attack it

newAI("move_simple", function(self)
	if self.ai_target.actor then
		local l = line.new(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y)
		local lx, ly = l()
		self:move(lx, ly)
	elseif self.ai_target.x and self.ai_target.y then
		local l = line.new(self.x, self.y, self.ai_target.x, self.ai_target.y)
		local lx, ly = l()
		self:move(lx, ly)
	end
end)

newAI("target_simple", function(self)
--	if self.ai_state.target_decay and self.ai_state.target_decay > 0 then
--	if game.turn % 100 ~= 0 then return end

	-- Find closer ennemy and target it
	self.ai_target.actor = nil
	core.fov.calc_circle(self.x, self.y, self.sight, function(self, lx, ly)
		if game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_sight") then return true end

		-- get and test the actor, if we are neutral or friendly, ignore it
		local act = game.level.map(lx, ly, Map.ACTOR)
		if not act then return end
		if self:reactionToward(act) >= 0 then return end

		-- If it is closer to the current target, target it
		if not self.ai_target.actor then
			self.ai_target.actor = act
		elseif core.fov.distance(self.x, self.y, act.x, act.y) < core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y) then
			self.ai_target.actor = act
		end
	end, function()end, self)
end)

newAI("simple", function(self)
	self:runAI("target_simple")
	self:runAI("move_simple")
end)
