newTalent{
	name = "Sword Mastery",
	type = {"physical/weapon-training", 1},
	points = 10,
	require = { stat = { str=function(level) return 10 + level * 3 end }, },
	mode = "passive",
	info = function(self)
		return [[Increases damage and attack with swords.]]
	end,
}

newTalent{
	name = "Axe Mastery",
	type = {"physical/weapon-training", 1},
	points = 10,
	require = { stat = { str=function(level) return 10 + level * 3 end }, },
	mode = "passive",
	info = function(self)
		return [[Increases damage and attack with axes.]]
	end,
}

newTalent{
	name = "Mace Mastery",
	type = {"physical/weapon-training", 1},
	points = 10,
	require = { stat = { str=function(level) return 10 + level * 3 end }, },
	mode = "passive",
	info = function(self)
		return [[Increases damage and attack with maces.]]
	end,
}

newTalent{
	name = "Knife Mastery",
	type = {"physical/weapon-training", 1},
	points = 10,
	require = { stat = { str=function(level) return 10 + level * 3 end }, },
	mode = "passive",
	info = function(self)
		return [[Increases damage and attack with knifes.]]
	end,
}
