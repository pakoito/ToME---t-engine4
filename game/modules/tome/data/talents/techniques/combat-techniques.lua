newTalent{
	name = "Precise Striking",
	type = {"technique/combat-techniques", 1},
	mode = "sustained",
	points = 5,
	require = techs_strdex_req1,
	cooldown = 30,
	sustain_stamina = 30,
	activate = function(self, t)
		return {
			speed = self:addTemporaryValue("combat_physspeed", 0.1 + self:getTalentLevel(t) / 20),
			atk = self:addTemporaryValue("combat_atk", 4 + (self:getTalentLevel(t) * self:getDex()) / 15),
			crit = self:addTemporaryValue("combat_physcrit", 4 + (self:getTalentLevel(t) * self:getDex()) / 25),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physspeed", p.speed)
		self:removeTemporaryValue("combat_physcrit", p.crit)
		self:removeTemporaryValue("combat_atk", p.atk)
		return true
	end,
	info = function(self, t)
		return ([[You focus your strikes, reducing your attack speed by %0.2f and increasing your attack by %d and critical chance by %d%%.]]):
		format(0.1 + self:getTalentLevel(t) / 20, 4 + (self:getTalentLevel(t) * self:getDex()) / 15, 4 + (self:getTalentLevel(t) * self:getDex()) / 25)
	end,
}

newTalent{
	name = "Blinding Speed",
	type = {"technique/combat-techniques", 2},
	points = 5,
	cooldown = 55,
	stamina = 25,
	require = techs_strdex_req2,
	action = function(self, t)
		self:setEffect(self.EFF_SPEED, 5, {power=1 + self:getTalentLevel(t) / 7})
		return true
	end,
	info = function(self, t)
		return ([[Through rigorous training you have learned to focus your actions for a short while, increasing your speed by %0.2f for 5 turns.]]):format(1 + self:getTalentLevel(t) / 7)
	end,
}

newTalent{
	name = "Perfect Strike",
	type = {"technique/combat-techniques", 3},
	points = 5,
	cooldown = 55,
	stamina = 25,
	require = techs_strdex_req3,
	action = function(self, t)
		self:setEffect(self.EFF_ATTACK, 1 + self:getTalentLevel(t), {power=100})
		return true
	end,
	info = function(self, t)
		return ([[You have learned to focus your blows to hit your target, granting +100 attack for %d turns.]]):format(1 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Rush",
	type = {"technique/combat-techniques", 4},
	message = "@Source@ rushes out!",
	require = techs_strdex_req4,
	points = 5,
	stamina = 45,
	cooldown = 50,
	tactical = {
		ATTACK = 4,
	},
	range = function(self, t) return math.floor(5 + self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > self:getTalentRange(t) then return nil end

		local l = line.new(self.x, self.y, x, y)
		local lx, ly = l()
		local tx, ty = lx, ly
		lx, ly = l()
		while lx and ly do
			if game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
			tx, ty = lx, ly
			lx, ly = l()
		end

		self:move(tx, ty, true)

		-- Attack ?
		if math.floor(core.fov.distance(self.x, self.y, x, y)) == 1 then
			self:attackTarget(target, nil, 1.2, true)
		end

		return true
	end,
	info = function(self, t)
		return ([[Rushes toward your target with incredible speed. If the target is reached you get a free attack doing 120% weapon damage.]])
	end,
}
