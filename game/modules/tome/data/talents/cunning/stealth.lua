newTalent{
	name = "Stealth",
	type = {"cunning/stealth", 1},
	mode = "sustained",
	points = 5,
	cooldown = 10,
	require = { stat = { cun=12 }, },
	activate = function(self, t)
		local armor = self:getInven("BODY")[1]
		if armor and (armor.subtype == "heavy" or armor.subtype == "massive") then
			game.logPlayer(self, "You cannot Stealth with such heavy armour!")
			return nil
		end

		-- Check nearby actors
		local grids = core.fov.circle_grids(self.x, self.y, math.floor(10 - self:getTalentLevel(t) * 1.3), true)
		for x, yy in pairs(grids) do for y in pairs(yy) do
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self and actor:reactionToward(self) < 0 then
				game.logPlayer(self, "You cannot Stealth with nearby foes watching!")
				return nil
			end
		end end

		return {
			stealth = self:addTemporaryValue("stealth", self:getCun(10) * self:getTalentLevel(t)),
			lite = self:addTemporaryValue("lite", -100),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("stealth", p.stealth)
		self:removeTemporaryValue("lite", p.lite)
		return true
	end,
	info = function(self, t)
		return ([[Enters stealth mode, making you harder to detect.
		While in stealth mode, light radius is reduced to 0.
		There needs to be no foes in sight in a radius of %d around you to enter stealth.]]):format(math.floor(10 - self:getTalentLevel(t) * 1.3))
	end,
}

newTalent{
	name = "Shadowstrike",
	type = {"cunning/stealth", 1},
	mode = "passive",
	points = 5,
	require = { stat = { cun=18 }, },
	info = function(self, t)
		return ([[When striking from stealth, hits are automatically criticals if the target does not notice you.
		Shadowstrikes do %.02f%% more damage than a normal hit.]]):format(math.floor(2 + self:getTalentLevel(t) / 5))
	end,
}
