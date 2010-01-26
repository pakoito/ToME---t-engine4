newAI("summoned", function(self)
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
