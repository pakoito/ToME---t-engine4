newTalent{
	name = "Berserker",
	type = {"technique/2hweapon-offense", 1},
	require = techs_req1,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_stamina = 40,
	activate = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Berserker without a two handed weapon!")
			return nil
		end

		return {
			atk = self:addTemporaryValue("combat_dam", 5 + self:getStr(7) * self:getTalentLevel(t)),
			dam = self:addTemporaryValue("combat_atk", 5 + self:getDex(7) * self:getTalentLevel(t)),
			def = self:addTemporaryValue("combat_def", -5 - 2 * (self:getTalentLevelRaw(t)-1)),
			armor = self:addTemporaryValue("combat_armor", -5 - 2 * (self:getTalentLevelRaw(t)-1)),
		}
	end,

	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_def", p.def)
		self:removeTemporaryValue("combat_armor", p.armor)
		self:removeTemporaryValue("combat_atk", p.atk)
		self:removeTemporaryValue("combat_dam", p.dam)
		return true
	end,
	info = function(self, t)
		return ([[Enters an aggressive battle stance, increasing attack by %d and damage by %d at the cost of %d defense and %d armor.]]):
		format(5 + self:getDex(7) * self:getTalentLevel(t), 5 + self:getStr(7) * self:getTalentLevel(t), -5 - 2 * (self:getTalentLevelRaw(t)-1), -5 - 2 * (self:getTalentLevelRaw(t)-1))
	end,
}

newTalent{
	name = "Death Dance",
	type = {"technique/2hweapon-offense", 2},
	require = techs_req2,
	points = 5,
	cooldown = 10,
	stamina = 30,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Death Dance without a two handed weapon!")
			return nil
		end

		for i = -1, 1 do for j = -1, 1 do
			local x, y = self.x + i, self.y + j
			if (self.x ~= x or self.y ~= y) and game.level.map:isBound(x, y) and game.level.map(x, y, Map.ACTOR) then
				local target = game.level.map(x, y, Map.ACTOR)
				self:attackTargetWith(target, weapon.combat, nil, 1.4 + self:getTalentLevel(t) / 8)
			end
		end end

		return true
	end,
	info = function(self, t)
		return ([[Spin around, extending your weapon and damaging all targets around for %d%% weapon damage.]]):format(100 * (1.4 + self:getTalentLevel(t) / 8))
	end,
}

newTalent{
	name = "Warshout",
	type = {"technique/2hweapon-offense",3},
	require = techs_req3,
	points = 5,
	stamina = 30,
	cooldown = 18,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 1,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Warshout without a two handed weapon!")
			return nil
		end

		local tg = {type="cone", range=0, radius=3 + self:getTalentLevelRaw(t), friendlyfire=false}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.CONFUSION, {
			dur=3+self:getTalentLevelRaw(t),
			dam=50+self:getTalentLevelRaw(t)*10,
			power_check=function() return self:combatAttackStr(weapon) end,
			resist_check=self.combatPhysicalResist,
		}, {type="flame"})
		return true
	end,
	info = function(self, t)
		return ([[Shout your warcry in a frontal cone, any targets caught inside will be confused for %d turns.]]):
		format(3 + self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Death Blow",
	type = {"technique/2hweapon-offense", 4},
	require = techs_req4,
	points = 5,
	cooldown = 30,
	stamina = 30,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Death Blow without a two handed weapon!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		local inc = self.stamina / 2
		if self:getTalentLevel(t) >= 4 then
			self.combat_dam = self.combat_dam + inc
		end
		self.combat_physcrit = self.combat_physcrit + 100

		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, 1.4 + self:getTalentLevel(t) / 6)

		if self:getTalentLevel(t) >= 4 then
			self.combat_dam = self.combat_dam - inc
			self.stamina = 0
		end
		self.combat_physcrit = self.combat_physcrit - 100

		-- Try to insta-kill
		if hit then
			if target:checkHit(self:combatAttackStr(weapon.combat), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("instadeath") and target.life > 0 and target.life < target.max_life * 0.2 then
				-- KILL IT !
				game.logSeen(target, "%s feels the pain of the death blow!", target.name:capitalize())
				target:takeHit(100000, self)
			elseif target.life > 0 and target.life < target.max_life * 0.2 then
				game.logSeen(target, "%s resists the death blow!", target.name:capitalize())
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Tries to perform a killing blow doing %d%% weapon damage, granting automatic critical hit. If the target ends up with low enough life it might be instantly killed.
		At level 4 it drains all remaining stamina and uses it to increase the blow damage.]]):format(100 * (1.4 + self:getTalentLevel(t) / 6))
	end,
}

-----------------------------------------------------------------------------
-- Cripple
-----------------------------------------------------------------------------
newTalent{
	name = "Stunning Blow",
	type = {"technique/2hweapon-cripple", 1},
	require = techs_req1,
	points = 5,
	cooldown = 6,
	stamina = 8,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Stunning Blow without a two handed weapon!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, 1.2 + self:getTalentLevel(t) / 10)

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttackStr(weapon.combat), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2 + self:getTalentLevel(t), {})
			else
				game.logSeen(target, "%s resists the stunning blow!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon doing %d%% damage, if the atatck hits, the target is stunned.]]):format(100 * (1.2 + self:getTalentLevel(t) / 10))
	end,
}

newTalent{
	name = "Sunder Armour",
	type = {"technique/2hweapon-cripple", 2},
	require = techs_req2,
	points = 5,
	cooldown = 6,
	stamina = 12,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Sunder Armour without a two handed weapon!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, 1.5 + self:getTalentLevel(t) / 10)

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttackStr(weapon.combat), target:combatPhysicalResist(), 0, 95, 10 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_SUNDER_ARMOUR, 4 + self:getTalentLevel(t), {power=5*self:getTalentLevel(t)})
			else
				game.logSeen(target, "%s resists the sundering!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon doing %d%% damage, if the attack hits, the target's armour is reduced by %d.]]):format(100 * (1.5 + self:getTalentLevel(t) / 10), 5*self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Sunder Arms",
	type = {"technique/2hweapon-cripple", 3},
	require = techs_req3,
	points = 5,
	cooldown = 6,
	stamina = 12,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Sunder Arms without a two handed weapon!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, 1.5 + self:getTalentLevel(t) / 10)

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttackStr(weapon.combat), target:combatPhysicalResist(), 0, 95, 10 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_SUNDER_ARMS, 4 + self:getTalentLevel(t), {power=3*self:getTalentLevel(t)})
			else
				game.logSeen(target, "%s resists the sundering!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon doing %d%% damage, if the attack hits, the target's attack power is reduced by %d.]]):format(100 * (1.5 + self:getTalentLevel(t) / 10), 3*self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Crush",
	type = {"technique/2hweapon-cripple", 4},
	require = techs_req4,
	points = 5,
	cooldown = 6,
	stamina = 12,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Crush without a two handed weapon!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, 1.4 + self:getTalentLevel(t) / 10)

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttackStr(weapon.combat), target:combatPhysicalResist(), 0, 95, 10 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_PINNED, 2 + self:getTalentLevel(t), {})
			else
				game.logSeen(target, "%s resists the crushing!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with a mighty blow to the legs doing %d%% weapon damage, if the attack hits, the target is unable to move for %d turns.]]):format(100 * (1.4 + self:getTalentLevel(t) / 10), 2+self:getTalentLevel(t))
	end,
}
