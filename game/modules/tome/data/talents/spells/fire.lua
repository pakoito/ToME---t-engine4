newTalent{
	name = "Globe of Light",
	type = {"spell/fire",1},
	mana = 5,
	cooldown = 14,
	tactical = {
		ATTACKAREA = 3,
	},
	action = function(self)
		local t = {type="ball", range=0, friendlyfire=false, radius=5 + self:combatSpellpower(0.2)}
		self:project(t, self.x, self.y, DamageType.LIGHT, 1)
		if self:knowTalent(Talents.T_GLOBE_OF_LIGHT) then
			self:project(t, self.x, self.y, DamageType.BLIND, 1)
		end
		return true
	end,
	require = { stat = { mag=10 }, },
	info = function(self)
		return ([[Creates a globe of pure light with a radius of %d that illuminates the area.
		The radius will increase with the Magic stat]]):format(5 + self:combatSpellpower(0.2))
	end,
}
newTalent{
	name = "Blinding Light",
	type = {"spell/fire", 2},
	mode = "passive",
	require = { stat = { mag=24 }, talent = { Talents.T_GLOBE_OF_LIGHT }, },
	info = function(self)
		return [[Globe of Light will also blind foes.]]
	end,
}

newTalent{
	name = "Flame",
	type = {"spell/fire",1},
	mana = 12,
	cooldown = 4,
	tactical = {
		ATTACK = 10,
	},
	action = function(self)
		local t = {type="bolt", range=20}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		self:project(t, x, y, DamageType.FIREBURN, self:spellCrit(15 + self:combatSpellpower(2.1)))
		return true
	end,
	require = { stat = { mag=10 }, },
	info = function(self)
		return ([[Conjures up a bolt of fire setting the target ablaze and doing %0.2f fire damage over 3 turns.
		The damage will increase with the Magic stat]]):format(15 + self:combatSpellpower(2.1))
	end,
}

newTalent{
	name = "Fireflash",
	type = {"spell/fire",2},
	mana = 40,
	cooldown = 8,
	tactical = {
		ATTACKAREA = 10,
	},
	action = function(self)
		local t = {type="ball", range=15, radius=math.min(6, 3 + self:combatSpellpower(0.06))}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		self:project(t, x, y, DamageType.FIRE, self:spellCrit(28 + self:combatSpellpower(1.2)))
		return true
	end,
	require = { stat = { mag=24 }, level=5, },
	info = function(self)
		return ([[Conjures up a flash of fire doing %0.2f fire damage in a radius of %d.
		The damage will increase with the Magic stat]]):format(28 + self:combatSpellpower(1.2), math.min(6, 3 + self:combatSpellpower(0.06)))
	end,
}

newTalent{
	name = "Inferno",
	type = {"spell/fire",4},
	mana = 200,
	cooldown = 30,
	tactical = {
		ATTACKAREA = 40,
	},
	action = function(self)
		local duration = 5 + self:combatSpellpower(0.25)
		local radius = 5
		local dam = 15 + self:combatSpellpower(1.6)
		local t = {type="ball", range=20, radius=radius}
		local x, y = self:getTarget(t)
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
	require = { stat = { mag=34 }, level=2},
	info = function(self)
		return ([[Raging flames burn foes and allies alike doing %0.2f netherflame damage in a radius of 5 each turns for %d turns.
		Cooldown: 8 turns
		The damage and duration will increase with the Magic stat]]):format(15 + self:combatSpellpower(1.6), 5 + self:combatSpellpower(0.25))
	end,
}
