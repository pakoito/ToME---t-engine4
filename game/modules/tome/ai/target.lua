-- Find an hostile target
-- this requires the ActorFOV interface, or an interface that provides self.fov.actors*
-- This is ToME specific, overriding the engine default target_simple to account for lite, infravision, ...
newAI("target_simple", function(self)
	if self.ai_target.actor and not self.ai_target.actor.dead and rng.percent(90) then return true end

	-- Find closer ennemy and target it
	-- Get list of actors ordered by distance
	local arr = self.fov.actors_dist
	local act
	local sqsense = math.max(self.lite, self.infravision or 0, self.heightened_senses or 0)
	sqsense = sqsense * sqsense
	for i = 1, #arr do
		act = self.fov.actors_dist[i]
--		print("AI looking for target", self.uid, self.name, "::", act.uid, act.name, self.fov.actors[act].sqdist)
		-- find the closest ennemy
		if act and self:reactionToward(act) < 0 and not act.dead and
			(
				-- If it has lite we can always see it
				(act.lite > 0)
				or
				-- Otherwise check if we can see it with our "senses"
				(self:canSee(act) and self.fov.actors[act].sqdist <= sqsense)
			) then

			self.ai_target.actor = act
			self:check("on_acquire_target", act)
			act:check("on_targeted", self)
			print("AI took for target", self.uid, self.name, "::", act.uid, act.name, self.fov.actors[act].sqdist, "<", sqsense)
			return true
		end
	end
end)

newAI("target_player_radius", function(self)
	if core.fov.distance(self.x, self.y, game.player.x, game.player.y) < self.ai_state.sense_radius then
		self.ai_target.actor = game.player
		return true
	end
end)
