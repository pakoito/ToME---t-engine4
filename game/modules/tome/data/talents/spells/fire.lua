newTalent{
	name = "Flame",
	type = {"spell/fire",1},
	require = spells_req1,
	points = 5,
	mana = 12,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIREBURN, self:spellCrit(25 + self:combatSpellpower(0.8) * self:getTalentLevel(t)), {type="flame"})
		return true
	end,
	info = function(self, t)
		return ([[Conjures up a bolt of fire setting the target ablaze and doing %0.2f fire damage over 3 turns.
		The damage will increase with the Magic stat]]):format(25 + self:combatSpellpower(0.8) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Flameshock",
	type = {"spell/fire",2},
	require = spells_req2,
	points = 5,
	mana = 30,
	cooldown = 18,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 1,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=3 + self:getTalentLevelRaw(t), friendlyfire=false}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FLAMESHOCK, {dur=self:getTalentLevelRaw(t), dam=self:spellCrit(10 + self:combatSpellpower(0.2) * self:getTalentLevel(t))}, {type="flame"})
		return true
	end,
	info = function(self, t)
		return ([[Conjures up a cone of flame. Any target caught in the area will take %0.2f fire damage and be stunned over %d turns.
		The damage will increase with the Magic stat]]):format(10 + self:combatSpellpower(0.2) * self:getTalentLevel(t), self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Fireflash",
	type = {"spell/fire",3},
	require = spells_req3,
	points = 5,
	mana = 40,
	cooldown = 8,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 15,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=1 + self:getTalentLevelRaw(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE, self:spellCrit(28 + self:combatSpellpower(0.4) * self:getTalentLevel(t)), {type="flame"})
		return true
	end,
	info = function(self, t)
		return ([[Conjures up a flash of fire doing %0.2f fire damage in a radius of %d.
		The damage will increase with the Magic stat]]):format(28 + self:combatSpellpower(0.4) * self:getTalentLevel(t), 1 + self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Inferno",
	type = {"spell/fire",4},
	require = spells_req4,
	points = 5,
	mana = 200,
	cooldown = 30,
	tactical = {
		ATTACKAREA = 40,
	},
	range = 20,
	action = function(self, t)
		local duration = 5 + self:getTalentLevel(t)
		local radius = 5
		local dam = 15 + self:combatSpellpower(0.15) * self:getTalentLevel(t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = game.target:pointAtRange(self.x, self.y, x, y, 15)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.NETHERFLAME, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=180, color_bg=30, color_bb=60}
		)
		return true
	end,
	info = function(self, t)
		return ([[Raging flames burn foes and allies alike doing %0.2f netherflame damage in a radius of 5 each turns for %d turns.
		The damage and duration will increase with the Magic stat]]):format(15 + self:combatSpellpower(0.15) * self:getTalentLevel(t), 5 + self:getTalentLevel(t))
	end,
}
