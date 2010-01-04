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
	points = 5,
	require = { stat = { con=function(level) return 14 + level * 5 end }, },
	on_learn = function(self, t)
		self.max_life = self.max_life + 40
	end,
	on_unlearn = function(self, t)
		self.max_life = self.max_life - 40
	end,
	info = function(self)
		return [[Increases your maximun life by 40 per talent level]]
	end,
}
