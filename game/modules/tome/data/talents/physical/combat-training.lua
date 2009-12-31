newTalent{
	name = "Heavy Armour Training",
	type = {"physical/combat-training", 1},
	mode = "passive",
	require = { stat = { str=18 }, },
	info = function(self)
		return [[Teaches the usage of heavy mail armours.]]
	end,
}

newTalent{
	name = "Massive Armour Training",
	type = {"physical/combat-training", 2},
	mode = "passive",
	require = { stat = { str=22 }, talent = { Talents.T_HEAVY_ARMOUR_TRAINING }, },
	info = function(self)
		return [[Teaches the usage of massive plate armours.]]
	end,
}

newTalent{
	name = "Health",
	type = {"physical/combat-training", 1},
	mode = "passive",
	require = { stat = { con=14 }, },
	on_learn = function(self, t)
		self.max_life = self.max_life + 50
	end,
	on_unlearn = function(self, t)
		self.max_life = self.max_life - 50
	end,
	info = function(self)
		return [[Increases your maximun life by 50]]
	end,
}

newTalent{
	name = "Greater Health",
	type = {"physical/combat-training", 2},
	mode = "passive",
	require = { stat = { con=24 }, talent = { Talents.T_HEALTH }, },
	on_learn = function(self, t)
		self.max_life = self.max_life + 70
	end,
	on_unlearn = function(self, t)
		self.max_life = self.max_life - 70
	end,
	info = function(self)
		return [[Increases your maximun life by 70]]
	end,
}

newTalent{
	name = "Supreme Health",
	type = {"physical/combat-training", 3},
	mode = "passive",
	require = { stat = { con=34 }, talent = { Talents.T_GREATER_HEALTH }, },
	on_learn = function(self, t)
		self.max_life = self.max_life + 90
	end,
	on_unlearn = function(self, t)
		self.max_life = self.max_life - 90
	end,
	info = function(self)
		return [[Increases your maximun life by 90]]
	end,
}
