newTalent{
	name = "Burrow",
	type = {"wild-gift/sand-drake", 1},
	require = gifts_req1,
	points = 5,
	mode = "sustained",
	sustain_equilibrium = 30,
	cooldown = 30,
	range = 20,
	activate = function(self, t)
		return {
			pass = self:addTemporaryValue("can_pass", {pass_wall=1}),
			dig = self:addTemporaryValue("move_project", {[DamageType.DIG]=1}),
			drain = self:addTemporaryValue("equilibrium_regen", 8 - self:getTalentLevelRaw(t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("equilibrium_regen", p.drain)
		self:removeTemporaryValue("move_project", p.dig)
		self:removeTemporaryValue("can_pass", p.pass)
		return true
	end,
	info = function(self, t)
		return ([[Allows to burrow into walls, increasing equilibrium quickly.
		Higher talent levels reduce equilibrium cost per turn.]])
	end,
}

newTalent{
	name = "Swallow",
	type = {"wild-gift/sand-drake", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 10,
	cooldown = 20,
	range = 1,
	message = "@Source@ swallows its target!",
	tactical = {
		ATTACK = 10,
	},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		if target.life * 100 / target.max_life > 10 + 3 * self:getTalentLevel(t) then
			return nil
		end

		if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("instakill") then
			target:die(self)
			self:incEquilibrium(-target.level - 5)
			self:heal(target.level * 2 + 5)
		else
			game.logSeen(target, "%s resists!", target.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		return ([[When your target is below %d life you can try to swallow it, killing it automatically regaining life and equilibrium.]]):
		format(10 + 3 * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Quake",
	type = {"wild-gift/sand-drake", 3},
	require = gifts_req3,
	points = 5,
	message = "@Source@ shakes the ground!",
	equilibrium = 4,
	cooldown = 30,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 20,
	action = function(self, t)
		local tg = {type="ball", range=0, friendlyfire=false, radius=2 + self:getTalentLevel(t) / 2, talent=t, no_restrict=true}
		self:project(tg, self.x, self.y, DamageType.PHYSKNOCKBACK, {dam=self:combatDamage() * 0.8, dist=4})
		self:doQuake(tg, self.x, self.y)
		return true
	end,
	info = function(self, t)
		return ([[You slam your foot onto the ground, shaking the area around you in a radius of %d, damage and knocking back your foes.
		The damage will increase with the Strength stat]]):format(2 + self:getTalentLevel(t) / 2)
	end,
}

newTalent{
	name = "Sand Breath",
	type = {"wild-gift/sand-drake", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ breathes sand!",
	tactical = {
		ATTACKAREA = 10,
	},
	range = 4,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=4 + self:getTalentLevelRaw(t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SAND, {dur=2+self:getTalentLevelRaw(t), dam=10 + self:getStr() * 0.3 * self:getTalentLevel(t)}, {type="flame"})
		return true
	end,
	info = function(self, t)
		return ([[You breath sand in a frontal cone. Any target caught in the area will take %0.2f physical damage and be blinded over %d turns.
		The damage will increase with the Strength stat]]):format(10 + self:getStr() * 0.3 * self:getTalentLevel(t), 2+self:getTalentLevelRaw(t))
	end,
}
