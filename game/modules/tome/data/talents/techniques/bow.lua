newTalent{
	name = "Bow Mastery",
	type = {"technique/archery-bow", 1},
	points = 10,
	require = { stat = { dex=function(level) return 12 + level * 3 end }, },
	mode = "passive",
	info = function(self, t)
		return [[Increases damage with bows.]]
	end,
}
