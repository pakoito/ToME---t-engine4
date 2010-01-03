newTalent{
	name = "Stunning Blow",
	type = {"physical/2hweapon", 1},
	points = 5,
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
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, 1)

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttackStr(weapon.combat), target:combatPhysicalResist(), 0, 95, 10 - self:getTalentLevel(t)) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2 + self:getTalentLevel(t), {})
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

newTalent{
	name = "Death Blow",
	type = {"physical/2hweapon", 2},
	points = 5,
	cooldown = 30,
	stamina = 15,
	require = { stat = { str=22 }, },
	action = function(self, t)
		local weapon = self:getInven("MAINHAND")[1]
		if not weapon or not weapon.twohanded then
			game.logPlayer(self, "You cannot use Death Blow without a two handed weapon!")
			return nil
		end

		local t = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(t)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		local inc = self.stamina / 2
		if self:getTalentLevel(t) >= 4 then
			self.combat_dam = self.combat_dam + inc
		end
		self.combat_physcrit = self.combat_physcrit + 100

		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, 1 + self:getTalentLevel(t) / 10)

		if self:getTalentLevel(t) >= 4 then
			self.combat_dam = self.combat_dam - inc
			self.stamina = 0
		end
		self.combat_physcrit = self.combat_physcrit - 100

		-- Try to insta-kill
		if hit then
			if target:checkHit(self:combatAttackStr(weapon.combat), target:combatPhysicalResist(), 0, 95, 10 - self:getTalentLevel(t)) and target:canBe("instadeath") and target.life > 0 and target.life < target.max_life * 0.2 then
				-- KILL IT !
				game.logSeen(target, "%s feels the pain of the death blow!", target.name:capitalize())
				target:takeHit(100000, self)
			elseif target.life > 0 and target.life < target.max_life * 0.2 then
				game.logSeen(target, "%s resists the death blow!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self)
		return ([[Hits the target with your weapon, if the atatck hits, the target is stunned.]])
	end,
}

newTalent{
	name = "Death Danse",
	type = {"physical/2hweapon", 3},
	points = 5,
	cooldown = 10,
	stamina = 30,
	require = { stat = { str=30 }, },
	action = function(self, t)
		local weapon = self:getInven("MAINHAND")[1]
		if not weapon or not weapon.twohanded then
			game.logPlayer(self, "You cannot use Death Danse without a two handed weapon!")
			return nil
		end

		for i = -1, 1 do for j = -1, 1 do
			local x, y = self.x + i, self.y + j
			if (self.x ~= x or self.y ~= y) and game.level.map:isBound(x, y) and game.level.map(x, y, Map.ACTOR) then
				local target = game.level.map(x, y, Map.ACTOR)
				self:attackTargetWith(target, weapon.combat, nil, 1 + self:getTalentLevel(t) / 8)
			end
		end end

		return true
	end,
	info = function(self)
		return ([[Spin around, extending your weapon and damaging all targets aruond.]])
	end,
}

newTalent{
	name = "Berserker",
	type = {"physical/2hweapon", 3},
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 100,
	require = { stat = { str=20 }, },
	activate = function(self, t)
		local weapon = self:getInven("MAINHAND")[1]
		if not weapon or not weapon.twohanded then
			game.logPlayer(self, "You cannot use Berserker without a two handed weapon!")
			return nil
		end

		return {
			atk = self:addTemporaryValue("combat_dam", 5 + self:getStr(4) * self:getTalentLevel(t)),
			dam = self:addTemporaryValue("combat_atk", 5 + self:getDex(4) * self:getTalentLevel(t)),
			def = self:addTemporaryValue("combat_def", -5),
			armor = self:addTemporaryValue("combat_armor", -5),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_def", p.def)
		self:removeTemporaryValue("combat_armor", p.armor)
		self:removeTemporaryValue("combat_atk", p.atk)
		self:removeTemporaryValue("combat_dam", p.dam)
		return true
	end,
	info = function(self)
		return ([[Enters a protective battle stance, increasing attack and damage at the cost of defense and armor.]])
	end,
}
