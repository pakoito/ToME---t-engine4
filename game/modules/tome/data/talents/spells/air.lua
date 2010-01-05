newTalent{
	name = "Lightning",
	type = {"spell/air", 1},
	points = 5,
	mana = 10,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(1, self:spellCrit(20 + self:combatSpellpower(0.8) * self:getTalentLevel(t)), 3))
		return true
	end,
	require = { stat = { mag=10 }, },
	info = function(self, t)
		return ([[Conjures up mana into a powerful beam of lightning doing 1 to %0.2f damage
		The damage will increase with the Magic stat]]):format(20 + self:combatSpellpower(0.8) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Noxious Cloud",
	type = {"spell/air",1},
	points = 5,
	mana = 45,
	cooldown = 8,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 15,
	action = function(self, t)
		local duration = self:getTalentLevel(t)
		local radius = 3
		local dam = 4 + self:combatSpellpower(0.11) * self:getTalentLevel(t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = game.target:pointAtRange(self.x, self.y, x, y, 15)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.NATURE, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=30, color_bg=180, color_bb=60}
		)
		return true
	end,
	require = { stat = { mag=16 }, },
	info = function(self, t)
		return ([[Noxious fumes raises from the ground doing %0.2f nature damage in a radius of 3 each turns for %d turns.
		The damage and duration will increase with the Magic stat]]):format(4 + self:combatSpellpower(0.11) * self:getTalentLevel(t), self:getTalentLevel(t))
	end,
}
