newTalent{
	name = "Ent-draught",
	type = {"spell/water", 1},
	mana = 10,
	cooldown = 100,
	action = function(self, t)
		return true
	end,
	require = { stat = { mag=10 }, },
	info = function(self)
		return ([[Confures some Ent-draught to fill your stomach.]])
	end,
}

newTalent{
	name = "Freeze",
	type = {"spell/water", 1},
	mana = 14,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	action = function(self, t)
		local t = {type="hit", range=self:getTalentRange(t)}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		self:project(t, x, y, DamageType.COLD, self:spellCrit(7 + self:combatSpellpower(1.2)))
		self:project(t, x, y, DamageType.FREEZE, 2)
		return true
	end,
	require = { stat = { mag=14 }, },
	info = function(self)
		return ([[Condenses ambiant water on a target, freezing it for a short while.
		The damage will increase with the Magic stat]]):format(7 + self:combatSpellpower(1.2))
	end,
}

newTalent{
	name = "Tidal Wave",
	type = {"spell/water",2},
	mana = 55,
	cooldown = 8,
	tactical = {
		ATTACKAREA = 10,
	},
	action = function(self, t)
		local duration = 5 + self:combatSpellpower(0.05)
		local radius = 1
		local dam = 12 + self:combatSpellpower(0.5)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.WAVE, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=30, color_bg=60, color_bb=200},
			function(e)
				e.radius = e.radius + 1
			end,
			false
		)
		return true
	end,
	require = { stat = { mag=34 }, level=25 },
	info = function(self)
		return ([[A furious ice storm rages around the caster doing %0.2f cold damage in a radius of 3 each turns for %d turns.
		The damage and duration will increase with the Magic stat]]):format(12 + self:combatSpellpower(0.5), 5 + self:combatSpellpower(0.05))
	end,
}

newTalent{
	name = "Ice Storm",
	type = {"spell/water",4},
	mana = 100,
	cooldown = 30,
	tactical = {
		ATTACKAREA = 20,
	},
	action = function(self, t)
		local duration = 5 + self:combatSpellpower(0.25)
		local radius = 3
		local dam = 12 + self:combatSpellpower(0.8)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.COLD, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=30, color_bg=60, color_bb=200},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
			end,
			false
		)
		return true
	end,
	require = { stat = { mag=34 }, level=25 },
	info = function(self)
		return ([[A furious ice storm rages around the caster doing %0.2f cold damage in a radius of 3 each turns for %d turns.
		The damage and duration will increase with the Magic stat]]):format(12 + self:combatSpellpower(0.8), 5 + self:combatSpellpower(0.25))
	end,
}
