-- Some randomly gained talents

------------------------------------------------------------
-- Slime Powers!
------------------------------------------------------------
newTalentType{ type="physical/slime", name = "slime powers", description = "Through dedicated consumption of slime mold juice you have gained an affinity with them." }

newTalent{
	name = "Poisonous Spores",
	type = {"physical/slime", 1},
	message = "@Source@ releases poisonous spores at @target@.",
	cooldown = 10,
	range = 1,
	action = function(self, t)
		local t = {type="hit", range=self:getTalentRange(t)}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self:attackTarget(target, DamageType.POISON, 1.5, true)
		return true
	end,
	info = function(self)
		return ([[Releases poisonous spores at the target.]])
	end,
}
