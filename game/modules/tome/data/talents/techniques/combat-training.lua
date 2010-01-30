newTalent{
	name = "Heavy Armour Training",
	type = {"technique/combat-training", 1},
	mode = "passive",
	points = 5,
	require = { stat = { str=18 }, },
	info = function(self, t)
		return ([[Teaches the usage of heavy mail armours. Increases amour value by %d when wearing a heavy mail armour.]]):
		format(self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Massive Armour Training",
	type = {"technique/combat-training", 2},
	mode = "passive",
	points = 5,
	require = { stat = { str=22 }, talent = { Talents.T_HEAVY_ARMOUR_TRAINING }, },
	info = function(self, t)
		return ([[Teaches the usage of massive plate armours. Increases amour value by %d when wearing a massive plate armour.]]):
		format(self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Health",
	type = {"technique/combat-training", 1},
	mode = "passive",
	points = 5,
	require = { stat = { con=function(level) return 14 + level * 3 end }, },
	on_learn = function(self, t)
		self.max_life = self.max_life + 40
	end,
	on_unlearn = function(self, t)
		self.max_life = self.max_life - 40
	end,
	info = function(self, t)
		return ([[Increases your maximun life by %d]]):format(40 * self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Weapon Combat",
	type = {"technique/combat-training", 1},
	points = 10,
	require = { level=function(level) return (level - 1) * 2 end },
	mode = "passive",
	info = function(self, t)
		return [[Increases chances to hit with melee weapons.]]
	end,
}
newTalent{
	name = "Sword Mastery",
	type = {"technique/combat-training", 1},
	points = 10,
	require = { stat = { str=function(level) return 12 + level * 3 end }, },
	mode = "passive",
	info = function(self, t)
		return [[Increases damage with swords.]]
	end,
}

newTalent{
	name = "Axe Mastery",
	type = {"technique/combat-training", 1},
	points = 10,
	require = { stat = { str=function(level) return 12 + level * 3 end }, },
	mode = "passive",
	info = function(self, t)
		return [[Increases damage with axes.]]
	end,
}

newTalent{
	name = "Mace Mastery",
	type = {"technique/combat-training", 1},
	points = 10,
	require = { stat = { str=function(level) return 14 + level * 3 end }, },
	mode = "passive",
	info = function(self, t)
		return [[Increases damage with maces.]]
	end,
}

newTalent{
	name = "Knife Mastery",
	type = {"technique/combat-training", 1},
	points = 10,
	require = { stat = { dex=function(level) return 10 + level * 3 end }, },
	mode = "passive",
	info = function(self, t)
		return [[Increases damage with knives.]]
	end,
}
