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

newTalent{
	name = "Piercing Arrow",
	type = {"technique/archery-bow", 2},
	no_energy = true,
	points = 5,
	cooldown = 8,
	stamina = 15,
	require = techs_dex_req2,
	range = 20,
	action = function(self, t)
		self.combat_apr = self.combat_apr + 1000
		self:archeryShoot(nil, 1.2 + self:getTalentLevel(t) / 7, nil, {type="beam"}, {one_shot=true})
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self, t)
		return ([[You fire an arrow that cuts right throught anything, piercing multiple targets if possible with near infinite armor penetration, doing %d%% damage.]]):format(100 * (1.2 + self:getTalentLevel(t) / 7))
	end,
}

newTalent{
	name = "Dual Arrows",
	type = {"technique/archery-bow", 3},
	no_energy = true,
	points = 5,
	cooldown = 8,
	stamina = 15,
	require = techs_dex_req3,
	range = 20,
	action = function(self, t)
		self:archeryShoot(nil, 1.2 + self:getTalentLevel(t) / 5, nil, {type="ball", radius=1}, {limit_shots=2})
		return true
	end,
	info = function(self, t)
		return ([[You fire two arrows at your target, hitting it and a nearby foes if possible, doing %d%% damage.]]):format(100 * (1.2 + self:getTalentLevel(t) / 5))
	end,
}

newTalent{
	name = "Volley of Arrows",
	type = {"technique/archery-bow", 4},
	no_energy = true,
	points = 5,
	cooldown = 20,
	stamina = 35,
	require = techs_dex_req4,
	range = 20,
	action = function(self, t)
		self:archeryShoot(nil, 0.7 + self:getTalentLevel(t) / 5, nil, {type="ball", radius=2 + self:getTalentLevel(t)/3, firendlyfire=false})
		return true
	end,
	info = function(self, t)
		return ([[You fire multiple arrows at the area, doing %d%% damage.]]):format(100 * (0.7 + self:getTalentLevel(t) / 5))
	end,
}
