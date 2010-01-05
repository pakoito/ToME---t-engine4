newTalent{
	name = "Weapon Combat",
	type = {"physical/weapon-training", 1},
	points = 10,
	require = { level=function(level) return (level - 1) * 2 end },
	mode = "passive",
	info = function(self, t)
		return [[Increases chances to hit with melee weapons.]]
	end,
}
newTalent{
	name = "Sword Mastery",
	type = {"physical/weapon-training", 1},
	points = 10,
	require = { stat = { str=function(level) return 12 + level * 3 end }, },
	mode = "passive",
	info = function(self, t)
		return [[Increases damage with swords.]]
	end,
}

newTalent{
	name = "Axe Mastery",
	type = {"physical/weapon-training", 1},
	points = 10,
	require = { stat = { str=function(level) return 12 + level * 3 end }, },
	mode = "passive",
	info = function(self, t)
		return [[Increases damage with axes.]]
	end,
}

newTalent{
	name = "Mace Mastery",
	type = {"physical/weapon-training", 1},
	points = 10,
	require = { stat = { str=function(level) return 14 + level * 3 end }, },
	mode = "passive",
	info = function(self, t)
		return [[Increases damage with maces.]]
	end,
}

newTalent{
	name = "Knife Mastery",
	type = {"physical/weapon-training", 1},
	points = 10,
	require = { stat = { dex=function(level) return 10 + level * 3 end }, },
	mode = "passive",
	info = function(self, t)
		return [[Increases damage with knifes.]]
	end,
}
