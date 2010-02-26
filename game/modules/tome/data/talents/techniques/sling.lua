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

newTalent{
	name = "Eye Shot",
	type = {"technique/archery-sling", 2},
	no_energy = true,
	points = 5,
	cooldown = 8,
	stamina = 15,
	require = techs_dex_req2,
	action = function(self, t)
		self:archeryShoot(nil, 1.2 + self:getTalentLevel(t) / 5, function(target, x, y)
			if target:checkHit(self:combatAttackDex(), target:combatPhysicalResist(), 0, 95, 10) and target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, 2 + self:getTalentLevelRaw(t), {})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[You fire a shot to your target's eyes, blinding it for %d turns and doing %d%% damage.]]):format(2 + self:getTalentLevelRaw(t), 100 * (1.2 + self:getTalentLevel(t) / 5))
	end,
}

newTalent{
	name = "Inertial Shot",
	type = {"technique/archery-sling", 3},
	no_energy = true,
	points = 5,
	cooldown = 8,
	stamina = 15,
	require = techs_dex_req3,
	action = function(self, t)
		self:archeryShoot(nil, 1.2 + self:getTalentLevel(t) / 5, function(target, x, y)
			if target:checkHit(self:combatAttackDex(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockBack(self.x, self.y, 4)
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the wave!", target.name:capitalize())
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[You fire a mighty shot at your target doing %d%% damage and knocking it back.]]):format(100 * (1.2 + self:getTalentLevel(t) / 5))
	end,
}

newTalent{
	name = "Multishots",
	type = {"technique/archery-sling", 4},
	no_energy = true,
	points = 5,
	cooldown = 20,
	stamina = 35,
	require = techs_dex_req4,
	action = function(self, t)
		self:archeryShoot(nil, 0.7 + self:getTalentLevel(t) / 5, nil, nil, {multishots=2+self:getTalentLevelRaw(t)/2})
		return true
	end,
	info = function(self, t)
		return ([[You fire %d shots at your target, doing %d%% damage with each shots.]]):format(2+self:getTalentLevelRaw(t)/2, 100 * (0.7 + self:getTalentLevel(t) / 5))
	end,
}
