-- Defines a simple AI building blocks
-- Target nearest and move/attack it

newAI("move_simple", function(self)
	if self.ai_target.actor then
		return self:moveDirection(self.ai_target.actor.x, self.ai_target.actor.y)
	elseif self.ai_target.x and self.ai_target.y then
		self:move(self.ai_target.x, self.ai_target.y)
	end
end)

newAI("target_simple", function(self)
	if self.ai_target.actor and not self.ai_target.actor.dead and rng.percent(90) then return true end

	-- Find closer ennemy and target it
	-- Get list of actors ordered by distance
	local arr = game.level:getDistances(self)
	local act
	if not arr or #arr == 0 then
		-- No target? Ask the distancer to find one
		game.level:idleProcessActor(self)
		return
	end
	for i = 1, #arr do
		act = __uids[arr[i].uid]

		-- find the closest ennemy
		if act and self:reactionToward(act) < 0 then
			self.ai_target.actor = act
			return true
		end
	end

	-- No target ? Ask for more
	game.level:idleProcessActor(self)
end)

newAI("target_player", function(self)
	self.ai_target.actor = game.player
end)

newAI("simple", function(self)
	if self:runAI("target_simple") then
		self:runAI("move_simple")
	end
end)
