-- Default archery attack
newTalent{
	name = "Critical Shot",
	type = {"technique/archery-training", 4},
	points = 1,
	range = 20,
	action = function(self, t)
		local weapon = self:hasArcheryWeapon()
		if not weapon then
			game.logPlayer(self, "You must wield a bow or a sling!")
			return nil
		end

		local tg = {type="bolt", range=self:getTalentRange(t), min_range=5 - self:getTalentLevelRaw(self.T_POINT_BLANK_SHOT)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end

		-- First attack with offhand
		local speed, hit = self:attackTargetWith(target, offweapon.combat, nil, 1.2 + self:getTalentLevel(t) / 10)

		-- Second attack with mainhand
		if hit then
			if target:checkHit(self:combatAttackDex(weapon.combat), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2 + self:getTalentLevel(t), {})
			else
				game.logSeen(target, "%s resists the stunning strike!", target.name:capitalize())
			end

			-- Attack after the stun, to benefit from backstabs
			self:attackTargetWith(target, weapon.combat, nil, 1.2 + self:getTalentLevel(t) / 10)
		end

		return true
	end,
	info = function(self, t)
		return ([[Increases attack speed by %0.2f, but drains stamina quickly.]]):format(-0.1 - self:getTalentLevel(t) / 14)
	end,
}

newTalent{
	name = "Point Blank Shot",
	type = {"technique/archery-training", 1},
	mode = "passive",
	points = 5,
	require = techs_dex_req1,
	info = function(self, t)
		return ([[Allows to fire at shorter range, reducing your dead-zone to %d.]]):format(5 - self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Aim",
	type = {"technique/archery-training", 2},
	mode = "sustained",
	points = 5,
	require = techs_dex_req2,
	cooldown = 30,
	sustain_stamina = 50,
	activate = function(self, t)
		local weapon, offweapon = self:hasArcheryWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Aim without a bow or sling!")
			return nil
		end

		return {
			apr = self:addTemporaryValue("combat_apr", 4 + (self:getTalentLevel(t) * self:getDex()) / 20),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_apr", p.apr)
		return true
	end,
	info = function(self, t)
		return ([[You enter a calm, focused, stance, increasing your damage(+%d), attack(+%d), armor peneration(+%d) and critical chance(+%d%%) but reducing your firing speed by %0.2f.]]):format(4 + (self:getTalentLevel(t) * self:getDex()) / 20)
	end,
}

newTalent{
	name = "Rapid Shot",
	type = {"technique/archery-training", 3},
	mode = "sustained",
	points = 5,
	require = techs_dex_req3,
	cooldown = 30,
	sustain_stamina = 50,
	activate = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Precision without dual wielding!")
			return nil
		end

		return {
			apr = self:addTemporaryValue("combat_apr", 4 + (self:getTalentLevel(t) * self:getDex()) / 20),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_apr", p.apr)
		return true
	end,
	info = function(self, t)
		return ([[You have learned to hit the right spot, increasing your armor penetration by %d.]]):format(4 + (self:getTalentLevel(t) * self:getDex()) / 20)
	end,
}

newTalent{
	name = "Critical Shot",
	type = {"technique/archery-training", 4},
	points = 5,
	cooldown = 30,
	sustain_stamina = 50,
	require = techs_dex_req4,
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Dual Strike without dual wielding!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		-- First attack with offhand
		local speed, hit = self:attackTargetWith(target, offweapon.combat, nil, 1.2 + self:getTalentLevel(t) / 10)

		-- Second attack with mainhand
		if hit then
			if target:checkHit(self:combatAttackDex(weapon.combat), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2 + self:getTalentLevel(t), {})
			else
				game.logSeen(target, "%s resists the stunning strike!", target.name:capitalize())
			end

			-- Attack after the stun, to benefit from backstabs
			self:attackTargetWith(target, weapon.combat, nil, 1.2 + self:getTalentLevel(t) / 10)
		end

		return true
	end,
	info = function(self, t)
		return ([[Increases attack speed by %0.2f, but drains stamina quickly.]]):format(-0.1 - self:getTalentLevel(t) / 14)
	end,
}
