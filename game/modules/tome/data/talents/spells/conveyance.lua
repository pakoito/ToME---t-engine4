newTalent{
	name = "Phase Door",
	type = {"spell/conveyance",1},
	message = "@Source@ blinks.",
	require = spells_req1,
	points = 5,
	mana = 10,
	cooldown = 8,
	tactical = {
		ESCAPE = 4,
	},
	action = function(self, t)
		local target = self

		if self:getTalentLevel(t) >= 5 then
--			local tx, ty = self:getTarget{type="hit", range=10}
--			if tx and ty then
--				target = game.level.map(tx, ty, Map.ACTOR) or self
--			end
		end

		local x, y = self.x, self.y
		if self:getTalentLevel(t) >= 4 then
			x, y = self:getTarget{type="ball", range=10 + self:combatSpellpower(0.1), radius=7 - self:getTalentLevel(t)}
			if not x then return nil end
			-- Target code doesnot restrict the target coordinates to the range, it lets the poject function do it
			-- but we cant ...
			x, y = game.target:pointAtRange(self.x, self.y, x, y, 10 + self:combatSpellpower(0.1))
			target:teleportRandom(x, y, 7 - self:getTalentLevel(t))
		else
			target:teleportRandom(x, y, 10 + self:combatSpellpower(0.1))
		end
		return true
	end,
	info = function(self, t)
		return ([[Teleports you randomly on a small scale range (%d)
		At level 4 it allows to specify the target area.
		At level 5 it allows to choose the target to teleport.
		The range will increase with the Magic stat]]):format(10 + self:combatSpellpower(0.1))
	end,
}

newTalent{
	name = "Teleport",
	type = {"spell/conveyance",2},
	message = "@Source@ teleports away.",
	require = spells_req2,
	points = 5,
	mana = 20,
	cooldown = 30,
	tactical = {
		ESCAPE = 8,
	},
	action = function(self, t)
		local target = self

		if self:getTalentLevel(t) >= 5 then
			local tx, ty = self:getTarget{default_target=self, type="hit", range=10}
			if tx and ty then
				target = game.level.map(tx, ty, Map.ACTOR) or self
			end
		end

		local x, y = self.x, self.y
		if self:getTalentLevel(t) >= 4 then
			x, y = self:getTarget{type="ball", range=100 + self:combatSpellpower(1), radius=20 - self:getTalentLevel(t)}
			if not x then return nil end
			-- Target code doesnot restrict the target coordinates to the range, it lets the poject function do it
			-- but we cant ...
			x, y = game.target:pointAtRange(self.x, self.y, x, y, 10 + self:combatSpellpower(0.1))
			target:teleportRandom(x, y, 20 - self:getTalentLevel(t))
		else
			target:teleportRandom(x, y, 100 + self:combatSpellpower(1))
		end
		return true
	end,
	info = function(self, t)
		return ([[Teleports you randomly on a small scale range (%d)
		At level 4 it allows to specify the target area.
		At level 5 it allows to choose the target to teleport.
		The range will increase with the Magic stat]]):format(10 + self:combatSpellpower(0.1))
	end,
}

newTalent{
	name = "Recall",
	type = {"spell/conveyance",3},
	require = spells_req3,
	points = 5,
	mana = 30,
	cooldown = 10,
	action = function(self, t)
--[[
		local target = self
		local tx, ty = self.x, self.y
		if self:knowTalent(Talents.T_TELEKINESIS) or self:knowTalent(Talents.T_IMPERIOUS_SUMMON) then
			local tx, ty = self:getTarget{default_target=self, type="hit", range=20}
			if tx and ty then
				target = game.level.map(tx, ty, Map.ACTOR) or self
			end
		end

		if
]]
		game.log("IMPLEMENT ME!")
		return true
	end,
	info = function(self, t)
		return ([[Recalls you to your home town after a few turns.]])
	end,
}

newTalent{
	name = "Probability Travel",
	type = {"spell/conveyance",4},
	mode = "sustained",
	require = spells_req4,
	points = 1,
	points = 2,
	cooldown = 40,
	sustain_mana = 100,
	tactical = {
		MOVEMENT = 20,
	},
	activate = function(self, t)
		self:attr("prob_travel", 1)
		return true
	end,
	deactivate = function(self, t)
		self:attr("prob_travel", -1)
		return true
	end,
	info = function(self, t)
		return ([[When you hit a solid surface this spell tears down the laws of probability to make you instantly appear on the other side.]])
	end,
}
