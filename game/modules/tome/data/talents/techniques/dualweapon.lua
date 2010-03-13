newTalent{
	name = "Dual Weapon Training",
	type = {"technique/dualweapon-training", 1},
	mode = "passive",
	points = 5,
	require = techs_dex_req1,
	info = function(self, t)
		return ([[Increases the damage of the off-hand weapon to %d%%.]]):format(100 / (2 - self:getTalentLevel(t) / 6))
	end,
}

newTalent{
	name = "Dual Weapon Defense",
	type = {"technique/dualweapon-training", 2},
	mode = "passive",
	points = 5,
	require = techs_dex_req2,
	info = function(self, t)
		return ([[You have learned to block incomming blows with your weapons increasing your defense by %d.]]):format(4 + (self:getTalentLevel(t) * self:getDex()) / 12)
	end,
}

newTalent{
	name = "Precision",
	type = {"technique/dualweapon-training", 3},
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
	name = "Momentum",
	type = {"technique/dualweapon-training", 4},
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 50,
	require = techs_dex_req4,
	activate = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Momentum without dual wielding!")
			return nil
		end

		return {
			combat_physspeed = self:addTemporaryValue("combat_physspeed", -self:combatSpeed(weapon.combat) * (self:getTalentLevel(t) * 0.14)),
			stamina_regen = self:addTemporaryValue("stamina_regen", -6),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physspeed", p.combat_physspeed)
		self:removeTemporaryValue("stamina_regen", p.stamina_regen)
		return true
	end,
	info = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		weapon = weapon or {}
		return ([[Increases attack speed by %d%%, but drains stamina quickly.]]):format(self:combatSpeed(weapon.combat) * (self:getTalentLevel(t) * 14))
	end,
}

------------------------------------------------------
-- Attacks
------------------------------------------------------
newTalent{
	name = "Dual Strike",
	type = {"technique/dualweapon-attack", 1},
	points = 5,
	cooldown = 12,
	stamina = 15,
	require = techs_dex_req1,
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
		return ([[Hit with your offhand weapon for %d%% damage, if the attack hits the target is stunned and you hit it with your mainhand weapon.]]):format(100 * (1.2 + self:getTalentLevel(t) / 10))
	end,
}

newTalent{
	name = "Flurry",
	type = {"technique/dualweapon-attack", 2},
	points = 5,
	cooldown = 12,
	stamina = 15,
	require = techs_dex_req2,
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Flurry without dual wielding!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self:attackTarget(target, nil, 0.8 + self:getTalentLevel(t) / 10, true)
		self:attackTarget(target, nil, 0.8 + self:getTalentLevel(t) / 10, true)
		self:attackTarget(target, nil, 0.8 + self:getTalentLevel(t) / 10, true)

		return true
	end,
	info = function(self, t)
		return ([[Lashes out a flurry of blows, hitting your target three times with each weapons for %d%% damage.]]):format(100 * (0.8 + self:getTalentLevel(t) / 10))
	end,
}

newTalent{
	name = "Sweep",
	type = {"technique/dualweapon-attack", 3},
	points = 5,
	cooldown = 8,
	stamina = 30,
	require = techs_dex_req3,
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Sweep without dual wielding!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		local dir = util.getDir(x, y, self.x, self.y)
		local lx, ly = util.coordAddDir(self.x, self.y, dir_sides[dir].left)
		local rx, ry = util.coordAddDir(self.x, self.y, dir_sides[dir].right)
		local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

		local hit
		hit = self:attackTarget(target, nil, 1.2 + self:getTalentLevel(t) / 10, true)
		if hit and target:canBe("cut") then target:setEffect(target.EFF_CUT, 3 + self:getTalentLevel(t), {power=self:getDex() * 0.5, src=self}) end

		if lt then
			hit = self:attackTarget(lt, nil, 1.2 + self:getTalentLevel(t) / 10, true)
			if hit and lt:canBe("cut") then lt:setEffect(lt.EFF_CUT, 3 + self:getTalentLevel(t), {power=self:getDex() * 0.5, src=self}) end
		end

		if rt then
			hit = self:attackTarget(rt, nil, 1.2 + self:getTalentLevel(t) / 10, true)
			if hit and rt:canBe("cut") then rt:setEffect(rt.EFF_CUT, 3 + self:getTalentLevel(t), {power=self:getDex() * 0.5, src=self}) end
		end
		print(x,y,target)
		print(lx,ly,lt)
		print(rx,ry,rt)

		return true
	end,
	info = function(self, t)
		return ([[Attack your foes in a frontal arc doing %d%% weapon damage and making your targets bleed for %d each turn for %d turns.]]):
		format(100 * (1.2 + self:getTalentLevel(t) / 10), self:getDex() * 0.5, 3 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Whirlwind",
	type = {"technique/dualweapon-attack", 4},
	points = 5,
	cooldown = 8,
	stamina = 30,
	require = techs_dex_req4,
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Whirlwind without dual wielding!")
			return nil
		end

		for i = -1, 1 do for j = -1, 1 do
			local x, y = self.x + i, self.y + j
			if (self.x ~= x or self.y ~= y) and game.level.map:isBound(x, y) and game.level.map(x, y, Map.ACTOR) then
				local target = game.level.map(x, y, Map.ACTOR)
				self:attackTarget(target, nil, 1.4 + self:getTalentLevel(t) / 10, true)
			end
		end end

		return true
	end,
	info = function(self, t)
		return ([[Spin around, damaging all targets around with both weapons for %d%%.]]):format(100 * (1.4 + self:getTalentLevel(t) / 10))
	end,
}
