-- Defines AIs that can use talents, either smartly or "dumbly"

-- Randomly use talents
newAI("dumb_talented", function(self)
	-- Find available talents
	local avail = {}
	local target_dist = math.floor(core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y))
	for tid, _ in pairs(self.talents) do
		local t = self:getTalentFromId(tid)
		if t.mode == "activated" and not self:isTalentCoolingDown(t) and target_dist <= self:getTalentRange(t) and self:preUseTalent(t, true) and self:canProject({type="bolt"}, self.ai_target.actor.x, self.ai_target.actor.y) then
			avail[#avail+1] = tid
			print(self.name, self.uid, "dumb ai talents can use", t.name, tid)
		end
	end
	if #avail > 0 then
		local tid = avail[rng.range(1, #avail)]
		print("dumb ai uses", tid)
		self:useTalent(tid)
		return true
	end
end)

newAI("dumb_talented_simple", function(self)
	if self:runAI("target_simple") then
		-- One in "talent_in" chance of using a talent
		if rng.chance(self.ai_state.talent_in or 6) and self:reactionToward(self.ai_target.actor) < 0 then
			self:runAI("dumb_talented")
		end
		if not self.energy.used then
			self:runAI(self.ai_move or "move_simple")
		end
		return true
	end
end)
