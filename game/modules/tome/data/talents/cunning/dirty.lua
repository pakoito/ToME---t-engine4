newTalent{
	name = "Lethality",
	type = {"cunning/dirty", 1},
	mode = "passive",
	points = 5,
	require = { stat = { cun=20 }, },
	info = function(self, t)
		return ([[You have learned to find and hit the weak spots. Your strikes have %0.2f%% more chances to be critical hits.
		Also when using knives you now use your cunning score instead of your strength for bonus damage.]]):format(1 + self:getTalentLevel(t) * 1.3)
	end,
}
