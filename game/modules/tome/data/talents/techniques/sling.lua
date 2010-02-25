newTalent{
	name = "Sling Mastery",
	type = {"technique/archery-sling", 1},
	points = 10,
	require = { stat = { dex=function(level) return 12 + level * 3 end }, },
	mode = "passive",
	info = function(self, t)
		return [[Increases damage with slings.]]
	end,
}
