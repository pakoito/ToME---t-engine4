newTalent{
	name = "Dual Weapon Training",
	type = {"physical/dualweapon", 1},
	mode = "passive",
	points = 5,
	require = { stat = { dex=14 } },
	info = function(self)
		return ([[Reduces the damage penality of the off-hand weapon]])
	end,
}

newTalent{
	name = "Flurry",
	type = {"physical/dualweapon", 1},
	points = 5,
	cooldown = 12,
	stamina = 15,
	require = { stat = { dex=12 }, },
	action = function(self, t)
		local weapon = self:getInven("MAINHAND")[1]
		local offweapon = self:getInven("OFFHAND")[1]
		if not weapon or not offweapon or not weapon.combat or not offweapon.combat then
			game.logPlayer(self, "You cannot use Flurry without dual wielding!")
			return nil
		end

		local t = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(t)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self:attackTarget(target, nil, 0.8 + self:getTalentLevel(t) / 10, true)
		self:attackTarget(target, nil, 0.8 + self:getTalentLevel(t) / 10, true)
		self:attackTarget(target, nil, 0.8 + self:getTalentLevel(t) / 10, true)

		return true
	end,
	info = function(self)
		return ([[Lashes out a flurry of blows, hiting your target three times with each weapons.]])
	end,
}

newTalent{
	name = "Whirlwind",
	type = {"physical/dualweapon", 3},
	points = 5,
	cooldown = 8,
	stamina = 30,
	require = { stat = { dex=24 }, },
	action = function(self, t)
		local weapon = self:getInven("MAINHAND")[1]
		local offweapon = self:getInven("OFFHAND")[1]
		if not weapon or not offweapon or not weapon.combat or not offweapon.combat then
			game.logPlayer(self, "You cannot use Whirlwind without dual wielding!")
			return nil
		end

		for i = -1, 1 do for j = -1, 1 do
			local x, y = self.x + i, self.y + j
			if (self.x ~= x or self.y ~= y) and game.level.map:isBound(x, y) and game.level.map(x, y, Map.ACTOR) then
				local target = game.level.map(x, y, Map.ACTOR)
				self:attackTarget(target, nil, 1 + self:getTalentLevel(t) / 10, true)
			end
		end end

		return true
	end,
	info = function(self)
		return ([[Spin around, damaging all targets around with both weapons.]])
	end,
}

newTalent{
	name = "Momentum",
	type = {"physical/dualweapon", 3},
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 50,
	require = { stat = { dex=20 }, },
	activate = function(self, t)
		local weapon = self:getInven("MAINHAND")[1]
		local offweapon = self:getInven("OFFHAND")[1]
		if not weapon or not offweapon or not weapon.combat or not offweapon.combat then
			game.logPlayer(self, "You cannot use Flurry without dual wielding!")
			return nil
		end

		return {
			combat_physspeed = self:addTemporaryValue("combat_physspeed", -0.1 - self:getTalentLevel(t) / 10),
			stamina_regen = self:addTemporaryValue("stamina_regen", -5),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physspeed", p.combat_physspeed)
		self:removeTemporaryValue("stamina_regen", p.stamina_regen)
		return true
	end,
	info = function(self)
		return ([[Greatly increases attack speed, but drains stamina quickly.]])
	end,
}


newTalent{
	name = "Momentum",
	type = {"physical/dualweapon", 3},
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 50,
	require = { stat = { dex=20 }, },
	activate = function(self, t)
		local weapon = self:getInven("MAINHAND")[1]
		local offweapon = self:getInven("OFFHAND")[1]
		if not weapon or not offweapon or not weapon.combat or not offweapon.combat then
			game.logPlayer(self, "You cannot use Flurry without dual wielding!")
			return nil
		end

		return {
			combat_physspeed = self:addTemporaryValue("combat_physspeed", -0.1 - self:getTalentLevel(t) / 10),
			stamina_regen = self:addTemporaryValue("stamina_regen", -5),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physspeed", p.combat_physspeed)
		self:removeTemporaryValue("stamina_regen", p.stamina_regen)
		return true
	end,
	info = function(self)
		return ([[Greatly increases attack speed, but drains stamina quickly.]])
	end,
}
