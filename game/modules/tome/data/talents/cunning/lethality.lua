newTalent{
	name = "Lethality",
	type = {"cunning/lethality", 1},
	mode = "passive",
	points = 5,
	require = cuns_req1,
	info = function(self, t)
		return ([[You have learned to find and hit the weak spots. Your strikes have %0.2f%% more chances to be critical hits.
		Also when using knives you now use your cunning score instead of your strength for bonus damage.]]):format(1 + self:getTalentLevel(t) * 1.3)
	end,
}

newTalent{
	name = "Deadly Strikes",
	type = {"cunning/lethality", 2},
	points = 5,
	cooldown = 12,
	stamina = 15,
	require = cuns_req2,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, 0.8 + self:getTalentLevel(t) / 10, true)

		if hitted then
			local dur = 5 + math.ceil(self:getTalentLevel(t))
			local power = 4 + (self:getTalentLevel(t) * self:getCun()) / 20
			self:setEffect(self.EFF_DEADLY_STRIKES, dur, {power=power})
		end

		return true
	end,
	info = function(self, t)
		return ([[You hit your target doing %d%% damage. If your attack hits you gain %d armour penetration for %d turns
		The APR will increase with Cunning.]]):
		format(100 * (0.8 + self:getTalentLevel(t) / 10), 4 + (self:getTalentLevel(t) * self:getCun()) / 20, 5 + math.ceil(self:getTalentLevel(t)))
	end,
}