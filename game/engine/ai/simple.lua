-- Defines a simple AI building blocks
-- Target nearest and move/attack it

newAI("move_simple", function(self)
	if self.ai_target.actor then
		local tx, ty = self:aiSeeTargetPos(self.ai_target.actor)
		return self:moveDirection(tx, ty)
	end
end)

newAI("target_simple", function(self)
	if self.ai_target.actor and not self.ai_target.actor.dead and rng.percent(90) then return true end

	-- Find closer ennemy and target it
	-- Get list of actors ordered by distance
	local arr = self.fov.actors_dist
	local act
	for i = 1, #arr do
		act = self.fov.actors_dist[i]
--		print("AI looking for target", self.uid, self.name, "::", act.uid, act.name, self.fov.actors[act].sqdist)
		-- find the closest ennemy
		if act and self:reactionToward(act) < 0 and not act.dead then
			self.ai_target.actor = act
			return true
		end
	end
end)

newAI("target_player", function(self)
	self.ai_target.actor = game.player
	return true
end)

newAI("simple", function(self)
	if self:runAI("target_simple") then
		return self:runAI("move_simple")
	end
	return false
end)
