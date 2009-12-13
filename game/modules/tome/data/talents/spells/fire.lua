newTalent{
	name = "Globe of Light",
	type = {"spell/fire",1},
	mana = 5,
	tactical = {
		ATTACKAREA = 3,
	},
	action = function(self)
		local t = {type="ball", range=0, friendlyfire=false, radius=5 + self:combatSpellpower(0.1)}
		self:project(t, self.x, self.y, DamageType.LIGHT, 1)
		return true
	end,
	require = { stat = { mag=10 }, },
	info = function(self)
		return ([[Creates a globe of pure light with a radius of %d that illuminates the area.
		The radius will increase with the Magic stat]]):format(5 + self:combatSpellpower(0.1))
	end,
}

newTalent{
	name = "Fireflash",
	type = {"spell/fire",2},
	mana = 35,
	cooldown = 6,
	tactical = {
		ATTACKAREA = 10,
	},
	action = function(self)
		local t = {type="ball", range=15, radius=math.min(6, 3 + self:combatSpellpower(0.06))}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		self:project(t, x, y, DamageType.FIRE, 28 + self:combatSpellpower(0.7))
		return true
	end,
	require = { stat = { mag=16 }, },
	info = function(self)
		return ([[Conjures up a flash of fire doing %0.2f fire damage in a radius of %d.
		Cooldown: 6 turns
		The damage will increase with the Magic stat]]):format(8 + self:combatSpellpower(0.7), math.min(6, 3 + self:combatSpellpower(0.06)))
	end,
}
