newTalent{
	name = "Arcane Combat",
	type = {"technique/magical-combat", 1},
	mode = "passive",
	points = 1,
	require = { stat = { mag=14, dex=12 }, },
	info = function(self, t)
		return ([[The user has learned how to blend the sword and the word, and is able to substitute her Magic stat to her Strength stat for the purpose of meeting techniques requirements.]]):
		format()
	end,
}
