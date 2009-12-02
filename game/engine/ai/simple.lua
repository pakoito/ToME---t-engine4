-- Defines a simple AI building blocks
-- Target nearest and move/attack it

newAI("move_simple", function(self)
	if self.ai_target.actor then
		local l = line.new(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y)
		local lx, ly = l()
		if lx and ly then
			self:move(lx, ly)
		end
	elseif self.ai_target.x and self.ai_target.y then
		local l = line.new(self.x, self.y, self.ai_target.x, self.ai_target.y)
		local lx, ly = l()
		if lx and ly then
			self:move(lx, ly)
		end
	end
end)

newAI("target_simple", function(self)
	-- Find new target every 10 +0speed turns or when no target exist
	if self.ai_target.actor then return end

	-- Find closer ennemy and target it
	self.ai_target.actor = nil
	for uid, act in pairs(game.level.entities) do
		if act ~= self and self:reactionToward(act) < 0 then
--		if game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_sight") then return true end
--		if not self:canMove(lx, ly, true) then return end
			-- If it is closer to the current target, target it
			if not self.ai_target.actor then
				self.ai_target.actor = act
			elseif core.fov.distance(self.x, self.y, act.x, act.y) < core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y) then
				self.ai_target.actor = act
			end
		end
	end
--print("target=>", self.ai_target.actor)
end)

newAI("simple", function(self)
	self:runAI("target_simple")
--	self.ai_target.actor = game.player
	self:runAI("move_simple")
end)
