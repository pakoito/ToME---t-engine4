newAI("summoned", function(self)
	-- Run out of time ?
	if self.summon_time then
		self.summon_time = self.summon_time - 1
		if self.summon_time <= 0 then
			game.logPlayer(self.summoner, "#PINK#Your summoned %s disappears.", self.name)
			self.dead = true
			if game.level:hasEntity(self) then
				game.level:removeEntity(self)
				self:removed()
			end
		end
	end

	-- Do the normal AI, otherwise follows summoner
	if self:runAI("target_simple") then
		return self:runAI(self.ai_real)
	else
		self.ai_target.actor = self.summoner
		local ret = self:runAI(self.ai_real)
		self.ai_target.actor = nil
		return ret
	end
end)
