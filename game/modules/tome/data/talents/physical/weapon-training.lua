newTalent{
	name = "Sword Apprentice",
	type = {"physical/weapon-training", 1},
	mode = "passive",
	info = function(self)
		return [[Increases damage and attack with swords.]]
	end,
}
newTalent{
	name = "Sword Master",
	type = {"physical/weapon-training", 2},
	mode = "passive",
	points = 2,
	require = { stat = { str=18 }, level=10 },
	info = function(self)
		return [[Increases damage and attack with swords.]]
	end,
}
newTalent{
	name = "Sword Grand Master",
	type = {"physical/weapon-training", 3},
	mode = "passive",
	points = 3,
	require = { stat = { str=34 }, level=20 },
	info = function(self)
		return [[Increases damage and attack with swords.]]
	end,
}

newTalent{
	name = "Axe Apprentice",
	type = {"physical/weapon-training", 1},
	mode = "passive",
	info = function(self)
		return [[Increases damage and attack with axes.]]
	end,
}
newTalent{
	name = "Axe Master",
	type = {"physical/weapon-training", 2},
	mode = "passive",
	points = 2,
	require = { stat = { str=18 }, level=10 },
	info = function(self)
		return [[Increases damage and attack with axes.]]
	end,
}
newTalent{
	name = "Axe Grand Master",
	type = {"physical/weapon-training", 3},
	mode = "passive",
	points = 3,
	require = { stat = { str=34 }, level=20 },
	info = function(self)
		return [[Increases damage and attack with axes.]]
	end,
}

newTalent{
	name = "Mace Apprentice",
	type = {"physical/weapon-training", 1},
	mode = "passive",
	info = function(self)
		return [[Increases damage and attack with maces.]]
	end,
}
newTalent{
	name = "Mace Master",
	type = {"physical/weapon-training", 2},
	mode = "passive",
	points = 2,
	require = { stat = { str=18 }, level=10 },
	info = function(self)
		return [[Increases damage and attack with maces.]]
	end,
}
newTalent{
	name = "Mace Grand Master",
	type = {"physical/weapon-training", 3},
	mode = "passive",
	points = 3,
	require = { stat = { str=34 }, level=20 },
	info = function(self)
		return [[Increases damage and attack with maces.]]
	end,
}

newTalent{
	name = "Knife Apprentice",
	type = {"physical/weapon-training", 1},
	mode = "passive",
	info = function(self)
		return [[Increases damage and attack with knifes.]]
	end,
}
newTalent{
	name = "Knife Master",
	type = {"physical/weapon-training", 2},
	mode = "passive",
	points = 2,
	require = { stat = { dex=18 }, level=10 },
	info = function(self)
		return [[Increases damage and attack with knifes.]]
	end,
}
newTalent{
	name = "Knife Grand Master",
	type = {"physical/weapon-training", 3},
	mode = "passive",
	points = 3,
	require = { stat = { dex=34 }, level=20 },
	info = function(self)
		return [[Increases damage and attack with knifes.]]
	end,
}

