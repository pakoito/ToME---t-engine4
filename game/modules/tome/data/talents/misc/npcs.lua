-- race & classes
newTalentType{ type="physical/other", name = "other", hide = true, description = "Talents of the various entities of the world." }
newTalentType{ type="spell/other", name = "other", hide = true, description = "Talents of the various entities of the world." }
newTalentType{ type="other/other", name = "other", hide = true, description = "Talents of the various entities of the world." }

-- Multiply!!!
newTalent{
	name = "Multiply",
	type = {"other/other", 1},
	cooldown = 3,
	range = 20,
	action = function(self, t)
		print("Multiply *****BROKEN***** Fix it!")
		return nil
--[[
		if not self.can_multiply or self.can_multiply <= 0 then return nil end
		-- Find a place around to clone
		for i = -1, 1 do for j = -1, 1 do
			if not game.level.map:checkAllEntities(self.x + i, self.y + j, "block_move") then
				self.can_multiply = self.can_multiply - 1
				local a = self:clone()
				a.energy.val = 0
				a.exp_worth = 0.1
				a.inven = {}
				if a.can_multiply <= 0 then a:unlearnTalent(t.id) end
				print("multiplied", a.can_multiply, "uids", self.uid,"=>",a.uid, "::", self.player, a.player)
				a:move(self.x + i, self.y + j, true)
				game.level:addEntity(a)
				return true
			end
		end end
		return nil
]]
	end,
	info = function(self)
		return ([[Multiply yourself!]])
	end,
}

newTalent{
	short_name = "CRAWL_POISON",
	name = "Poisonous Crawl",
	type = {"physical/other", 1},
	points = 5,
	message = "@Source@ crawls poison onto @target@.",
	cooldown = 5,
	range = 1,
	action = function(self, t)
		local x, y, target = self:getTarget()
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.POISON, 2 + self:getTalentLevel(t), true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self)
		return ([[Crawl onto the target, convering it in poison.]])
	end,
}

newTalent{
	short_name = "CRAWL_ACID",
	name = "Acidic Crawl",
	points = 5,
	type = {"physical/other", 1},
	message = "@Source@ crawls acid onto @target@.",
	cooldown = 2,
	range = 1,
	action = function(self, t)
		local x, y, target = self:getTarget()
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.ACID, 1 + self:getTalentLevel(t) / 3, true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self)
		return ([[Crawl onto the target, convering it in acid.]])
	end,
}

newTalent{
	short_name = "SPORE_BLIND",
	name = "Blinding Spores",
	type = {"physical/other", 1},
	points = 5,
	message = "@Source@ releases blinding spores at @target@.",
	cooldown = 2,
	range = 1,
	action = function(self, t)
		local t = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(t)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.BLIND, 0.8 + self:getTalentLevel(t) / 10, true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self)
		return ([[Releases blinding spores at the target.]])
	end,
}

newTalent{
	short_name = "SPORE_POISON",
	name = "Poisonous Spores",
	type = {"physical/other", 1},
	points = 5,
	message = "@Source@ releases poisonous spores at @target@.",
	cooldown = 2,
	range = 1,
	action = function(self, t)
		local x, y, target = self:getTarget()
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.POISON, 2 + self:getTalentLevel(t), true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self)
		return ([[Releases poisonous spores at the target.]])
	end,
}

newTalent{
	name = "Stun",
	type = {"physical/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	action = function(self, t)
		local t = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(t)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hit = self:attackTarget(target, 0.5 + self:getTalentLevel(t) / 10, true)

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
		return ([[Hits the target with your weapon doing %d%% damage, if the atatck hits, the target is stunned.]]):format(100 * (0.5 + self:getTalentLevel(t) / 10))
	end,
}

newTalent{
	name = "Knockback",
	type = {"physical/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	action = function(self, t)
		local t = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(t)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hit = self:attackTarget(target, nil, 1.5 + self:getTalentLevel(t) / 10, true)

		-- Try to knockback !
		if hit then
			if target:checkHit(self:combatAttackStr(weapon.combat), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
				target:knockback(4)
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon doing %d%% damage, if the atatck hits, the target is knocked back.]]):format(100 * (1.5 + self:getTalentLevel(t) / 10))
	end,
}
