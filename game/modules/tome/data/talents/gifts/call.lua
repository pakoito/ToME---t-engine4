newTalent{
	name = "Meditation",
	type = {"wild-gift/call", 1},
	require = gifts_req1,
	points = 5,
	message = "@Source@ meditates on nature.",
	equilibrium = 0,
	cooldown = 300,
	range = 20,
	action = function(self, t)
		self:setEffect(self.EFF_STUNNED, 17 - self:getTalentLevel(t), {})
		self:incEquilibrium(-10 - self:getWil(50) * self:getTalentLevel(t))
		return true
	end,
	info = function(self, t)
		return ([[Meditate on your link with Nature. You are considered stunned for %d turns and regenerate %d equilibrium.
		The effect will incease with your Willpower stat.]]):
		format(17 - self:getTalentLevel(t), 10 + self:getWil(50) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "???",
	type = {"wild-gift/call", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 0,
	cooldown = 300,
	range = 20,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[Meditate on your link with Nature. You are considered stunned for %d turns and regenerate %d equilibrium.
		The effect will incease with your Willpower stat.]]):
		format(17 - self:getTalentLevel(t), 10 + self:getWil(50) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "???",
	type = {"wild-gift/call", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 0,
	cooldown = 300,
	range = 20,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[Meditate on your link with Nature. You are considered stunned for %d turns and regenerate %d equilibrium.
		The effect will incease with your Willpower stat.]]):
		format(17 - self:getTalentLevel(t), 10 + self:getWil(50) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Nature's Balance",
	type = {"wild-gift/call", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 20,
	cooldown = 50,
	range = 20,
	action = function(self, t)
		local nb = math.ceil(self:getTalentLevel(t) + 2)
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[2] <= self:getTalentLevelRaw(t) and tt.type[1]:find("^wild-gift/") then
				tids[#tids+1] = tid
			end
		end
		for i = 1, nb do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = nil
		end
		self.changed = true
		return true
	end,
	info = function(self, t)
		return ([[Your deep link with Nature allows you to reset the cooldown of %d of your wild gifts of level %d or less.]]):
		format(math.ceil(self:getTalentLevel(t) + 2), self:getTalentLevelRaw(t))
	end,
}
