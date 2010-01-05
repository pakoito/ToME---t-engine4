-- Some randomly gained talents

------------------------------------------------------------
-- Slime Powers!
------------------------------------------------------------
newTalentType{ type="slime/slime", name = "slime powers", description = "Through dedicated consumption of slime mold juice you have gained an affinity with them." }

newTalent{
	name = "Poisonous Spores",
	type = {"slime/slime", 1},
	points = 5,
	message = "@Source@ releases poisonous spores at @target@.",
	cooldown = 10,
	range = 1,
	action = function(self, t)
		local t = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(t)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.POISON, 1.5 + self:getTalentLevel(t) / 5, true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self)
		return ([[Releases poisonous spores at the target.]])
	end,
}
