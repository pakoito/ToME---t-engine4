newTalent{
	name = "Burrow",
	type = {"gift/sand", 1},
	require = gifts_req1,
	points = 5,
	message = "@Source@ burrows into the ground!",
	equilibrium = 10,
	cooldown = 150,
	range = 20,
	tactical = {
		DEFEND = 10,
	},
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[Burrows into the ground to protect yourself and regenerate life.]]):format(100 * (1.5 + self:getTalentLevel(t) / 4))
	end,
}

newTalent{
	name = "????",
	type = {"gift/sand", 2},
	require = gifts_req2,
	points = 5,
	mode = "sustained",
	message = "The skin of @Source@ starts dripping acid.",
	sustain_equilibrium = 25,
	cooldown = 10,
	range = 1,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		return true
	end,
	info = function(self, t)
		return ([[Your skin drips with acid, damaging all that hits your for %d acid damage.]]):format(10 + 5 * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "???????",
	type = {"gift/sand", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 4,
	cooldown = 30,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	action = function(self, t)
	end,
	info = function(self, t)
		return ([[Spit slime at your target doing %0.2f nature damage and slowing it down for 3 turns.
		The damage will increase with the Dexterity stat]]):format(20 + (self:getDex() * self:getTalentLevel(t)) * 0.3)
	end,
}

newTalent{
	name = "Sand Breath",
	type = {"gift/sand", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 12,
	cooldown = 12,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 4,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=4 + self:getTalentLevelRaw(t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SAND, {dur=2+self:getTalentLevelRaw(t), dam=10 + self:getStr() * 0.3 * self:getTalentLevel(t)}, {type="flame"})
		return true
	end,
	info = function(self, t)
		return ([[You breath sand in a frontal cone. Any target caught in the area will take %0.2f physical damage and be blinded over %d turns.
		The damage will increase with the Strength stat]]):format(10 + self:getStr() * 0.3 * self:getTalentLevel(t), 2+self:getTalentLevelRaw(t))
	end,
}
