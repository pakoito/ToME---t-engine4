-- Defines a simple AI building blocks
-- Target nearest and move/attack it

newAI("move_simple", function(self)
	if self.ai_target.actor then
		local act = __uids[self.ai_target.actor]
		local l = line.new(self.x, self.y, act.x, act.y)
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
	if self.got_target then return end

	-- Find closer ennemy and target it
	self.ai_target.actor = nil
	-- Get list of actors ordered by distance
	local arr = game.level:getDistances(self)
	local act
	if not arr or #arr == 0 then print("target abording, waiting on distancer") return end
	for i = 1, #arr do
		act = __uids[arr[i].uid]
		-- find the closest ennemy
		if self:reactionToward(act) < 0 then
			self.ai_target.actor = act.uid
			print("selected target", act.uid, "at dist", arr[i].dist)
			break
		end
	end
	self.got_target = true
--print("target=>", self.ai_target.actor)
end)

newAI("simple", function(self)
	self:runAI("target_simple")
--	self.ai_target.actor = game.player
	self:runAI("move_simple")
end)
