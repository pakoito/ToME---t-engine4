-- Defines some special movement AIs

-- Ghoul AI: move, pause, move pause, ...
newAI("move_ghoul", function(self)
	if self.ai_target.actor then
		if not rng.percent(self.ai_state.pause_chance or 30) then
			local tx, ty = self:aiSeeTargetPos(self.ai_target.actor)
			return self:moveDirection(tx, ty)
		else
			self:useEnergy()
			return true
		end
	end
end)

-- Snake AI: move in the general direction but "slide" along
newAI("move_snake", function(self)
	if self.ai_target.actor then
		local tx, ty = self:aiSeeTargetPos(self.ai_target.actor)
		-- We we are in striking distance, strike!
		if self:isNear(tx, ty) then
			return self:moveDirection(tx, ty)
		else
			local rd = rng.range(1, 3)
			if rd == 1 then
				-- nothing, we move in the coerct direction
			elseif rd == 2 then
				-- move to the left
				local dir = util.getDir(tx, ty, self.x, self.y)
				tx, ty = util.coordAddDir(self.x, self.y, dir_sides[dir].left)
			elseif rd == 3 then
				-- move to the right
				local dir = util.getDir(tx, ty, self.x, self.y)
				tx, ty = util.coordAddDir(self.x, self.y, dir_sides[dir].right)
			end
			return self:moveDirection(tx, ty)
		end
	end
end)
