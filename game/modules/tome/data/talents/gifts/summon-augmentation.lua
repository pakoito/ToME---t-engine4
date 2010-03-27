newTalent{
	name = "Rage",
	type = {"wild-gift/summon-augmentation", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 5,
	cooldown = 15,
	range = 20,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target or not target.summoner or not target.summoner == self then return nil end
		target:setEffect(target.EFF_ALL_STAT, 5, {power=2+math.floor(self:getTalentLevel(t) * 2)})
		return true
	end,
	info = function(self, t)
		return ([[Induces a killing rage in one of your summons, increasing its stats by %d.]]):format(2+math.floor(self:getTalentLevel(t) * 2))
	end,
}

newTalent{
	name = "Detonate",
	type = {"wild-gift/summon-augmentation", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 5,
	cooldown = 25,
	range = 20,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target or not target.summoner or not target.summoner == self then return nil end

		if target.name == "fire imp" then
			local tg = {type="ball", range=self:getTalentRange(t), radius=1 + self:getTalentLevelRaw(t), talent=t}
			target:project(tg, target.x, target.y, DamageType.FIRE, 28 + self:getWil(32) * self:getTalentLevel(t), {type="flame"})
			target:die()
		elseif target.name == "black jelly" then
			local tg = {type="ball", range=self:getTalentRange(t), radius=1 + self:getTalentLevelRaw(t), talent=t}
			target:project(tg, target.x, target.y, DamageType.SLIME, 18 + self:getWil(22) * self:getTalentLevel(t), {type="slime"})
			target:die()
		elseif target.name == "benevolent spirit" then
			local tg = {type="ball", range=self:getTalentRange(t), radius=1 + self:getTalentLevelRaw(t), talent=t}
			target:project(tg, target.x, target.y, function(tx, ty)
				local a = game.level.map(tx, ty, Map.ACTOR)
				if a and self:reactionToward(a) >= 0 then
					a:heal(10 + self:getWil(30) * self:getTalentLevel(t))
				end
			end, nil, {type="acid"})
			target:die()
		else
			game.logPlayer("You may not detonate this summon.")
			return nil
		end
		return true
	end,
	info = function(self, t)
		return ([[Destroys one of your summons, make it detonate.
		Only some summons can be detonated:
		- Fire Imp: Explodes into a fireball
		- Jelly: Explodes into a ball of slowing slime
		- Benevolent Spirit: Explodes into a ball of healing
		The effect improves with your Willpower.]]):format()
	end,
}

newTalent{
	name = "Resilience",
	type = {"wild-gift/summon-augmentation", 3},
	require = gifts_req3,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[Improves all your summons life time and Constitution.]])
	end,
}

newTalent{
	name = "Phase Summon",
	type = {"wild-gift/summon-augmentation", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 5,
	cooldown = 25,
	range = 20,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target or not target.summoner or not target.summoner == self then return nil end

		local dur = 1 + self:getTalentLevel(t)
		self:setEffect(self.EFF_EVASION, dur, {chance=50})
		target:setEffect(target.EFF_EVASION, dur, {chance=50})

		-- Displace
		game.level.map:remove(self.x, self.y, Map.ACTOR)
		game.level.map:remove(target.x, target.y, Map.ACTOR)
		game.level.map(self.x, self.y, Map.ACTOR, target)
		game.level.map(target.x, target.y, Map.ACTOR, self)
		self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y

		return true
	end,
	info = function(self, t)
		return ([[Switches places with one of your summons. This disorients your foes, granting both you and your summon 50%% evasion for %d turns.]]):format(1 + self:getTalentLevel(t))
	end,
}
