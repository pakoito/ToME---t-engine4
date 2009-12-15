newTalent{
	name = "Freeze",
	type = {"spell/water", 1},
	mana = 14,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	action = function(self)
		local t = {type="hit", range=20}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		self:project(t, x, y, DamageType.COLD, self:spellCrit(7 + self:combatSpellpower(0.7)))
		self:project(t, x, y, DamageType.FREEZE, 2)
		return true
	end,
	require = { stat = { mag=14 }, },
	info = function(self)
		return ([[Condenses ambiant water on a target, freezing it for a short while.
		The damage will increase with the Magic stat]]):format(7 + self:combatSpellpower(0.7))
	end,
}

newTalent{
	name = "Ice Storm",
	type = {"spell/water",2},
	mana = 45,
	cooldown = 30,
	tactical = {
		ATTACKAREA = 20,
	},
	action = function(self)
		local duration = 5 + self:combatSpellpower(0.25)
		local radius = 3
		local dam = 12 + self:combatSpellpower(0.20)
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
	require = { stat = { mag=16 }, },
	info = function(self)
		return ([[A furious ice storm rages around the caster doing %0.2f cold damage in a radius of 3 each turns for %d turns.
		The damage and duration will increase with the Magic stat]]):format(12 + self:combatSpellpower(0.20), 5 + self:combatSpellpower(0.25))
	end,
}
