newTalent{
	name = "Rage",
	type = {"gift/summon-augmentation", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 5,
	cooldown = 25,
	range = 20,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target then return nil end
		game.logPlayer("IMPLEMENT ME")
		return true
	end,
	info = function(self, t)
		return ([[Induces a killing rage in one of you melee summons, increase your target's damage by %d.
		Damage increase improves with your Magic stat.]]):format(10 + self:getWil() * self:getTalentLevel(t) / 5, 10 + self:getTalentLevel(t) * 2)
	end,
}
