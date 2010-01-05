newTalent{
	name = "Shield Bash",
	type = {"physical/shield", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	action = function(self, t)
		local shield = self:getInven("OFFHAND")[1]
		if not shield or not shield.special_combat then
			game.logPlayer(self, "You cannot use Shield Bash without a shield!")
			return nil
		end

		local t = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(t)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, 2 + self:getTalentLevel(t) / 5)

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
	info = function(self)
		return ([[Hits the target with a shield strike, stunning it.
		The damage multiplier increases with your strength.]])
	end,
}

newTalent{
	name = "Overpower",
	type = {"physical/shield", 2},
	points = 5,
	cooldown = 6,
	stamina = 16,
	require = { stat = { str=16 }, },
	action = function(self, t)
		local shield = self:getInven("OFFHAND")[1]
		if not shield or not shield.special_combat then
			game.logPlayer(self, "You cannot use Overpower without a shield!")
			return nil
		end

		local t = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(t)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		-- First attack with weapon
		self:attackTarget(target, nil, 1.8 + self:getTalentLevel(t) / 10, true)
		-- Second attack with shield
		self:attackTargetWith(target, shield.special_combat, nil, 1.8 + self:getTalentLevel(t) / 10)
		-- Third attack with shield
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, 1.8 + self:getTalentLevel(t) / 10)

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
	info = function(self)
		return ([[Hits the target with your weapon and two shield strikes, trying to overpower your target.
		If the last attack hits, the target is knocked back.]])
	end,
}

newTalent{
	name = "Repulsion",
	type = {"physical/shield", 2},
	points = 5,
	cooldown = 10,
	stamina = 30,
	require = { stat = { str=22 }, },
	action = function(self, t)
		local shield = self:getInven("OFFHAND")[1]
		if not shield or not shield.special_combat then
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
	info = function(self)
		return ([[Let all your foes pile up on your shield then put all your strengh in one mighty thurst and repel them all away.]])
	end,
}

newTalent{
	name = "Shield Wall",
	type = {"physical/shield", 3},
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 100,
	require = { stat = { str=28 }, },
	activate = function(self, t)
		local shield = self:getInven("OFFHAND")[1]
		if not shield or not shield.special_combat then
			game.logPlayer(self, "You cannot use Shield Wall without a shield!")
			return nil
		end

		local stun, knock
		if self:getTalentLevel(t) >= 5 then
			stun = self:addTemporaryValue("stun_immune", 1)
			knock = self:addTemporaryValue("knockback_immune", 1)
		end
		return {
			atk = self:addTemporaryValue("combat_dam", -5),
			dam = self:addTemporaryValue("combat_atk", -5),
			def = self:addTemporaryValue("combat_def", 5 + self:getDex(4) * self:getTalentLevel(t)),
			armor = self:addTemporaryValue("combat_armor", 5 + self:getCun(4) * self:getTalentLevel(t)),
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
	info = function(self)
		return ([[Enters a protective battle stance, incraesing defense and armor at the cost of attack and damage.
		At level 5 it also makes you immnue to stuns and knockbacks.]])
	end,
}
