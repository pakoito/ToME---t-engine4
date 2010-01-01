newTalent{
	name = "Stunning Blow",
	type = {"physical/2hweapon", 1},
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	action = function(self, t)
		local weapon = self:getInven("MAINHAND")[1]
		if not weapon or not weapon.twohanded then
			game.logPlayer(self, "You cannot use Stunning Blow without a two handed weapon!")
			return nil
		end

		local t = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(t)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon, nil, 1)

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttack(weapon), target:combatPhysicalResist(), 0, 95, 5) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2 + self:getStr(4), {})
			else
				game.logSeen(target, "%s resists the stunning blow!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self)
		return ([[Hits the target with your weapon, if the atatck hits, the target is stunned.]])
	end,
}
