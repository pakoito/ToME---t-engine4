newTalent{
	name = "Burrow",
	type = {"wild-gift/sand-drake", 1},
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
	name = "Swallow",
	type = {"wild-gift/sand-drake", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 10,
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
	name = "Quake",
	type = {"wild-gift/sand-drake", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 4,
	cooldown = 30,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 20,
	action = function(self, t)
		local tg = {type="ball", range=0, friendlyfire=false, radius=2 + self:getTalentLevel(t) / 2, talent=t, no_restrict=true}
		self:project(tg, self.x, self.y, DamageType.PHYSKNOCKBACK, {dam=self:combatDamage() * 0.8, dist=4})
		self:doQuake(tg, self.x, self.y)
		return true
	end,
	info = function(self, t)
		return ([[You slam your foot onto the ground, shaking the area around you in a radius of %d, damage and knocking back your foes.
		The damage will increase with the Strength stat]]):format(2 + self:getTalentLevel(t) / 2)
	end,
}

newTalent{
	name = "Sand Breath",
	type = {"wild-gift/sand-drake", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ breathes sand!",
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
