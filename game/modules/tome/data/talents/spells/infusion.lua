newTalent{
	name = "Acid Infusion",
	type = {"spell/infusion", 2},
	mode = "sustained",
	require = spells_req2,
	sustain_mana = 30,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getIncrease = function(self, t) return self:combatTalentScale(t, 0.05, 0.25) end,
	getConvert = function(self, t) return self:combatTalentLimit(t, 125, 15, 75, true) end, -- limit to 125%
	activate = function(self, t)
		cancelInfusions(self)
		game:playSoundNear(self, "talents/arcane")
		self.fire_convert_to = {DamageType.ACID, t.getConvert(self, t)}
		return {
		}
	end,
	deactivate = function(self, t, p)
		self.fire_convert_to = nil
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		local conv = t.getConvert(self, t)
		return ([[When you throw your alchemist bombs, you infuse them with explosive acid that can blind, increasing damage by %d%%.
		In addition all fire damage you do, from any source, is converted to %d%% acid damage (without any special effects).]]):
		format(100 * daminc, conv)
	end,
}

newTalent{
	name = "Lightning Infusion",
	type = {"spell/infusion", 3},
	mode = "sustained",
	require = spells_req3,
	sustain_mana = 30,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getIncrease = function(self, t) return self:combatTalentScale(t, 0.05, 0.25) end,
	getConvert = function(self, t) return self:combatTalentLimit(t, 125, 15, 75, true) end, -- limit to 125%
	activate = function(self, t)
		cancelInfusions(self)
		game:playSoundNear(self, "talents/arcane")
		self.fire_convert_to = {DamageType.LIGHTNING, t.getConvert(self, t)}
		return {
		}
	end,
	deactivate = function(self, t, p)
		self.fire_convert_to = nil
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		local conv = t.getConvert(self, t)
		return ([[When you throw your alchemist bombs, you infuse them with lightning that can daze, increasing damage by %d%%.
		In addition all fire damage you do, from any source, is converted to %d%% lightning damage (without any special effects).]]):
		format(100 * daminc, conv)
	end,
}

newTalent{
	name = "Frost Infusion",
	type = {"spell/infusion", 4},
	mode = "sustained",
	require = spells_req4,
	sustain_mana = 30,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getIncrease = function(self, t) return self:combatTalentScale(t, 0.05, 0.25) end,
	getConvert = function(self, t) return self:combatTalentLimit(t, 125, 15, 75, true) end, -- limit to 125%
	activate = function(self, t)
		cancelInfusions(self)
		game:playSoundNear(self, "talents/arcane")
		self.fire_convert_to = {DamageType.COLD, t.getConvert(self, t)}
		return {
		}
	end,
	deactivate = function(self, t, p)
		self.fire_convert_to = nil
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		local conv = t.getConvert(self, t)
		return ([[When you throw your alchemist bombs, you infuse them with frost that can freeze, increasing damage by %d%%.
		In addition all fire damage you do, from any source, is converted to %d%% cold damage (without any special effects).]]):
		format(100 * daminc, conv)
	end,
}
