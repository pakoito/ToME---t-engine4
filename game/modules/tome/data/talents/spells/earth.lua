newTalent{
	name = "Noxious Cloud",
	type = {"spell/earth",1},
	mana = 45,
	cooldown = 8,
	tactical = {
		ATTACKAREA = 10,
	},
	action = function(self)
		local duration = 5 + self:getMag(10)
		local radius = 3
		local t = {type="ball", range=15, radius=radius}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		x, y = game.target:pointAtRange(self.x, self.y, x, y, 15)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.NATURE, 4 + self:getMag(30),
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=30, color_bg=180, color_bb=60}
		)
		return true
	end,
	require = { stat = { mag=16 }, },
	info = function(self)
		return ([[Noxious fumes raises from the ground doing %0.2f nature damage in a radius of 3 each turns for %d turns.
		Cooldown: 8 turns
		The damage and duration will increase with the Magic stat]]):format(4 + self:getMag(30), 5 + self:getMag(10))
	end,
}

newTalent{
	name = "Stone Skin",
	type = {"spell/earth", 1},
	mode = "sustained",
	mana = 45,
	cooldown = 10,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self)
		local power = 1 + self:getMag(15)
		self.combat.armor = self.combat.armor + power
		return {power=power}
	end,
	deactivate = function(self, p)
		self.combat.armor = self.combat.armor - p.power
	end,
	require = { stat = { mag=14 }, },
	info = function(self)
		return ([[The caster skin grows as hard as stone, granting %d bonus to armor.
		The bonus to armor will increase with the Magic stat]]):format(1 + self:getMag(15))
	end,
}
