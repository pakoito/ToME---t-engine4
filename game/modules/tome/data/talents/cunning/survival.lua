newTalent{
	name = "Trap Detection",
	type = {"cunning/survival", 1},
	require = cuns_req1,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[Your attention to details allows you to detect traps around you (%d detection 'power').]]):
		format(self:getTalentLevel(t) * self:getCun(25))
	end,
}

newTalent{
	name = "Trap Disarm",
	type = {"cunning/survival", 1},
	require = cuns_req1,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[You have learned to disarm traps. (%d disarm power).]]):
		format(self:getTalentLevel(t) * self:getCun(25))
	end,
}
