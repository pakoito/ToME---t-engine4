newTalent{
	name = "Poisonous Spores",
	type = {"wild-gift/slime", 1},
	require = gifts_req1,
	points = 5,
	message = "@Source@ releases poisonous spores at @target@.",
	equilibrium = 2,
	cooldown = 10,
	range = 1,
	tactical = {
		ATTACK = 10,
	},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.POISON, 1.5 + self:getTalentLevel(t) / 4, true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self, t)
		return ([[Releases poisonous spores at the target doing %d%% weapon damage.]]):format(100 * (1.5 + self:getTalentLevel(t) / 4))
	end,
}

newTalent{
	name = "Acidic Skin",
	type = {"wild-gift/slime", 2},
	require = gifts_req2,
	points = 5,
	mode = "sustained",
	message = "The skin of @Source@ starts dripping acid.",
	sustain_equilibrium = 25,
	cooldown = 10,
	range = 1,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		local power = 10 + 5 * self:getTalentLevel(t)
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.ACID]=power}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		return true
	end,
	info = function(self, t)
		return ([[Your skin drips with acid, damaging all that hits your for %d acid damage.]]):format(10 + 5 * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Slime Spit",
	type = {"wild-gift/slime", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 4,
	cooldown = 30,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SLIME, 20 + (self:getDex() * self:getTalentLevel(t)) * 0.3, {type="slime"})
		return true
	end,
	info = function(self, t)
		return ([[Spit slime at your target doing %0.2f nature damage and slowing it down for 3 turns.
		The damage will increase with the Dexterity stat]]):format(20 + (self:getDex() * self:getTalentLevel(t)) * 0.3)
	end,
}

newTalent{
	name = "Slime Roots",
	type = {"wild-gift/slime", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 5,
	cooldown = 20,
	tactical = {
		MOVEMENT = 10,
	},
	range = 20,
	action = function(self, t)
		local x, y = self:getTarget{type="ball", range=20 + self:getTalentLevel(t), radius=math.min(0, 5 - self:getTalentLevel(t))}
		if not x then return nil end
		-- Target code doesnot restrict the self coordinates to the range, it lets the poject function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, 1, "slime")
		self:teleportRandom(x, y, 7 - self:getTalentLevel(t))
		game.level.map:particleEmitter(self.x, self.y, 1, "slime")

		-- Stunned!
		self:setEffect(self.EFF_STUNNED, util.bound(5 - self:getTalentLevel(t) / 2, 2, 7), {})
		return true
	end,
	info = function(self, t)
		return ([[You extend slimy roots into the ground, follow them and re-appear somewhere else in a range of %d.
		The process is quite a strain on your body and you will be stunned for %d turns.]]):format(20 + (self:getMag() * self:getTalentLevel(t)) * 0.3, util.bound(5 - self:getTalentLevel(t) / 2, 2, 7))
	end,
}
