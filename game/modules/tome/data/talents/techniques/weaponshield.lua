----------------------------------------------------------------------
-- Offense
----------------------------------------------------------------------

newTalent{
	name = "Shield Pummel",
	type = {"technique/shield-offense", 1},
	require = techs_req1,
	points = 5,
	cooldown = 6,
	stamina = 8,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Shield Pummel without a shield!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self:attackTargetWith(target, shield.special_combat, nil, 1.5 + self:getTalentLevel(t) / 5)
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, 1.3 + (self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE) / 2) / 5)

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttack(shield.special_combat), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2 + self:getTalentLevel(t) / 2, {})
			else
				game.logSeen(target, "%s resists the shield bash!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with two shield strikes, stunning it and doing %d%% shield damage.
		The damage multiplier increases with your strength.]]):format(100 * (1.3 + (self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE) / 2) / 5))
	end,
}

newTalent{
	name = "Riposte",
	type = {"technique/shield-offense", 2},
	require = techs_req2,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[When you block/avoid a melee blow you have %d%% chances to get a free, automatic, melee attack against your foe.]]):format(util.bound(self:getTalentLevel(t) * self:getDex(50), 10, 80))
	end,
}

newTalent{
	name = "Overpower",
	type = {"technique/shield-offense", 3},
	require = techs_req3,
	points = 5,
	cooldown = 8,
	stamina = 22,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Overpower without a shield!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		-- First attack with weapon
		self:attackTarget(target, nil, 0.8 + self:getTalentLevel(t) / 10, true)
		-- Second attack with shield
		self:attackTargetWith(target, shield.special_combat, nil, 0.8 + (self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE) / 2) / 10)
		-- Third attack with shield
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, 0.8 + (self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE)) / 10)

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttack(shield.special_combat), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
				target:knockBack(self.x, self.y, 4)
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon and two shield strikes doing %d%% damage, trying to overpower your target.
		If the last attack hits, the target is knocked back.]]):format(100 * (0.8 + (self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE) / 2) / 10))
	end,
}

newTalent{
	name = "Assault",
	type = {"technique/shield-offense", 4},
	require = techs_req4,
	points = 5,
	cooldown = 6,
	stamina = 16,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Assault without a shield!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		-- First attack with shield
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, 1 + (self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE) / 2) / 10)

		-- Second & third attack with weapon
		if hit then
			self.combat_physcrit = self.combat_physcrit + 1000
			self:attackTarget(target, nil, 1 + self:getTalentLevel(t) / 10, true)
			self:attackTarget(target, nil, 1 + self:getTalentLevel(t) / 10, true)
			self.combat_physcrit = self.combat_physcrit - 1000
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with shield doing %d%% damage. If it hits you follow up with 2 weapon strikes which are automatic crits.]]):
		format(100 * (1 + (self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE) / 2) / 10))
	end,
}


----------------------------------------------------------------------
-- Defense
----------------------------------------------------------------------
newTalent{
	name = "Shield Wall",
	type = {"technique/shield-defense", 1},
	require = techs_req1,
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 50,
	activate = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Shield Wall without a shield!")
			return nil
		end

		local stun, knock
		if self:getTalentLevel(t) >= 5 then
			stun = self:addTemporaryValue("stun_immune", 1)
			knock = self:addTemporaryValue("knockback_immune", 1)
		end
		return {
			atk = self:addTemporaryValue("combat_dam", -10),
			dam = self:addTemporaryValue("combat_atk", -10),
			def = self:addTemporaryValue("combat_def", 5 + self:getDex(4) * self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE) * 2),
			armor = self:addTemporaryValue("combat_armor", 5 + self:getCun(4) * self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE)),
			stun = stun,
			knock = knock
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_def", p.def)
		self:removeTemporaryValue("combat_armor", p.armor)
		self:removeTemporaryValue("combat_atk", p.atk)
		self:removeTemporaryValue("combat_dam", p.dam)
		if p.stun then self:removeTemporaryValue("stun_immune", p.stun) end
		if p.knock then self:removeTemporaryValue("knockback_immune", p.knock) end
		return true
	end,
	info = function(self, t)
		return ([[Enters a protective battle stance, increasing defense by %d and armor by %d at the cost of 10 attack and 10 damage.
		At level 5 it also makes you immnue to stuns and knockbacks.]]):format(
		5 + self:getDex(4) * self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE),
		5 + self:getCun(4) * self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE)
		)
	end,
}

newTalent{
	name = "Repulsion",
	type = {"technique/shield-defense", 2},
	require = techs_req2,
	points = 5,
	cooldown = 10,
	stamina = 30,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Repulsion without a shield!")
			return nil
		end

		for i = -1, 1 do for j = -1, 1 do
			local x, y = self.x + i, self.y + j
			if (self.x ~= x or self.y ~= y) and game.level.map:isBound(x, y) and game.level.map(x, y, Map.ACTOR) then
				local target = game.level.map(x, y, Map.ACTOR)
				if target:checkHit(self:combatAttack(shield.special_combat), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
					target:knockBack(self.x, self.y, 1 + self:getTalentLevel(t))
				else
					game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
				end
			end
		end end

		return true
	end,
	info = function(self, t)
		return ([[Let all your foes pile up on your shield then put all your strengh in one mighty thurst and repel them all away.]])
	end,
}

newTalent{
	name = "Shield Expertise",
	type = {"technique/shield-defense", 3},
	require = techs_req3,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self.combat_physresist = self.combat_physresist + 4
		self.combat_spellresist = self.combat_spellresist + 2
	end,
	on_unlearn = function(self, t)
		self.combat_physresist = self.combat_physresist + 4
		self.combat_spellresist = self.combat_spellresist + 2
	end,
	info = function(self, t)
		return ([[Improves your damage with shield attacks and increases your spell and physical resistance.]]):format()
	end,
}

newTalent{
	name = "Last Stand",
	type = {"technique/shield-defense", 4},
	require = techs_req4,
	mode = "sustained",
	points = 5,
	cooldown = 60,
	sustain_stamina = 90,
	activate = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Last Stand without a shield!")
			return nil
		end

		return {
			max_life = self:addTemporaryValue("max_life", 10 * self:getTalentLevel(t)),
			def = self:addTemporaryValue("combat_def", 5 + self:getDex(4) * self:getTalentLevel(t)),
			nomove = self:addTemporaryValue("never_move", 1),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_def", p.def)
		self:removeTemporaryValue("max_life", p.max_life)
		self:removeTemporaryValue("never_move", p.nomove)
		return true
	end,
	info = function(self, t)
		return ([[Brace yourself for the final stand, increasing defense by %d and maximun life by %d but makes you unable to move.]]):
		format(5 + self:getDex(4) * self:getTalentLevel(t), 10 * self:getTalentLevel(t))
	end,
}
