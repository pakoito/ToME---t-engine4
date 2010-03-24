newTalent{
	name = "Ice Claw",
	type = {"wild-gift/cold-drake", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 3,
	cooldown = 7,
	range = 1,
	tactical = {
		ATTACK = 10,
	},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self:attackTargetWith(target, DamageType.COLD, 1.4 + self:getTalentLevel(t) / 8, true)
		return true
	end,
	info = function(self, t)
		return ([[You call upon the mighty claw of a cold drake, doing %d%% weapon damage as cold damage.]]):format(100 * (1.4 + self:getTalentLevel(t) / 8))
	end,
}

newTalent{
	name = "Icy Skin",
	type = {"wild-gift/cold-drake", 2},
	require = gifts_req2,
	mode = "sustained",
	points = 5,
	sustain_equilibrium = 30,
	cooldown = 10,
	range = 20,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.COLD]=5 * self:getTalentLevel(t)}),
			armor = self:addTemporaryValue("combat_armor", 4 * self:getTalentLevel(t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("combat_armor", p.armor)
		return true
	end,
	info = function(self, t)
		return ([[Your skin forms icy scales, damaging all that hits your for %d cold damage and increasing your armor by %d.]]):format(5 * self:getTalentLevel(t), 4 * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Ice Wall",
	type = {"wild-gift/cold-drake", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 10,
	cooldown = 30,
	range = 20,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[You slam your foot onto the ground, shaking the area around you in a radius of %d, damage and knocking back your foes.
		The damage will increase with the Strength stat]]):format(2 + self:getTalentLevel(t) / 2)
	end,
}

newTalent{
	name = "Ice Breath",
	type = {"wild-gift/cold-drake", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ breathes ice!",
	tactical = {
		ATTACKAREA = 10,
	},
	range = 4,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=4 + self:getTalentLevelRaw(t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ICE, 10 + self:getStr() * 0.3 * self:getTalentLevel(t), {type="freeze"})
		return true
	end,
	info = function(self, t)
		return ([[You breath ice in a frontal cone. Any target caught in the area will take %0.2f cold damage and can be frozen for a few turns.
		The damage will increase with the Strength stat]]):format(10 + self:getStr() * 0.3 * self:getTalentLevel(t), 2+self:getTalentLevelRaw(t))
	end,
}
