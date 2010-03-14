local Map = require "engine.Map"

newTalent{
	name = "Dirty Fighting",
	type = {"cunning/dirty", 1},
	points = 5,
	cooldown = 12,
	stamina = 10,
	require = cuns_req1,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, 0.2 + self:getTalentLevel(t) / 12, true)

		if hitted then
			if target:checkHit(self:combatAttackDex(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 3 + math.ceil(self:getTalentLevel(t)), {})
			else
				game.logSeen(target, "%s resists the stun!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[You hit your target doing %d%% damage, trying to stun it instead of damaging it. If your attack hits the target is stunned for %d turns.]]):
		format(100 * (0.2 + self:getTalentLevel(t) / 12), 3 + math.ceil(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Backstab",
	type = {"cunning/dirty", 2},
	mode = "passive",
	points = 5,
	require = cuns_req2,
	info = function(self, t)
		return ([[Your quick wit gives you a big advantage against stunned targets, all your hits will have %d%% more chances of being critical.]]):
		format(self:getTalentLevel(t) * 10)
	end,
}
newTalent{
	name = "Switch Place",
	type = {"cunning/dirty", 3},
	points = 5,
	cooldown = 10,
	stamina = 50,
	require = cuns_req3,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, 0, true)

		if hitted then
			local dur = 1 + self:getTalentLevel(t)
			self:setEffect(self.EFF_EVASION, dur, {chance=50})

			-- Displace
			game.level.map:remove(self.x, self.y, Map.ACTOR)
			game.level.map:remove(target.x, target.y, Map.ACTOR)
			game.level.map(self.x, self.y, Map.ACTOR, target)
			game.level.map(target.x, target.y, Map.ACTOR, self)
			self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y
		end

		return true
	end,
	info = function(self, t)
		return ([[Using a serie of tricks and maneuvers you switch places with your target.
		Switch places will confuse your foes for a few turns, granting your evasion(50%%) for %d turns.]]):
		format(1 + self:getTalentLevel(t))
	end,
}

