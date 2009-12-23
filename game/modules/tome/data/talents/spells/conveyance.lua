newTalent{
	name = "Phase Door",
	type = {"spell/conveyance",1},
	message = "@Source@ blinks.",
	mana = 10,
	cooldown = 8,
	tactical = {
		ESCAPE = 4,
	},
	action = function(self, t)
		local target = self

		if self:knowTalent(Talents.T_TARGETED_TELEPORT) then
			local tx, ty = self:getTarget{default_target=self, type="hit", range=10}
			if tx and ty then
				target = game.level.map(tx, ty, Map.ACTOR) or self
			end
		end

		local x, y = self.x, self.y
		if self:knowTalent(Talents.T_CONTROLLED_TELEPORT) then
			x, y = self:getTarget{type="ball", range=10 + self:combatSpellpower(0.1), radius=5 - self:combatSpellpower(0.03)}
			if not x then return nil end
			-- Target code doesnot restrict the target coordinates to the range, it lets the poject function do it
			-- but we cant ...
			x, y = game.target:pointAtRange(self.x, self.y, x, y, 10 + self:combatSpellpower(0.1))
			target:teleportRandom(x, y, 5 - self:combatSpellpower(0.03))
		else
			target:teleportRandom(x, y, 10 + self:combatSpellpower(0.1))
		end
		return true
	end,
	require = { stat = { mag=15 }, },
	info = function(self)
		return ([[Teleports you randomly on a small scale range (%d)
		The range will increase with the Magic stat]]):format(10 + self:combatSpellpower(0.1))
	end,
}

newTalent{
	name = "Teleport",
	type = {"spell/conveyance",2},
	message = "@Source@ teleports away.",
	mana = 20,
	cooldown = 30,
	tactical = {
		ESCAPE = 8,
	},
	action = function(self, t)
		local target = self

		if self:knowTalent(Talents.T_TARGETED_TELEPORT) then
			local tx, ty = self:getTarget{default_target=self, type="hit", range=10}
			if tx and ty then
				target = game.level.map(tx, ty, Map.ACTOR) or self
			end
		end

		local x, y = self.x, self.y
		if self:knowTalent(Talents.T_CONTROLLED_TELEPORT) then
			x, y = self:getTarget{type="ball", range=100 + self:combatSpellpower(1), radius=5 - self:combatSpellpower(0.03)}
			if not x then return nil end
			-- Target code doesnot restrict the target coordinates to the range, it lets the poject function do it
			-- but we cant ...
			x, y = game.target:pointAtRange(self.x, self.y, x, y, 10 + self:combatSpellpower(0.1))
			target:teleportRandom(x, y, 5 - self:combatSpellpower(0.03))
		else
			target:teleportRandom(x, y, 100 + self:combatSpellpower(1))
		end
		return true
	end,
	require = { stat = { mag=24 }, },
	info = function(self)
		return ([[Teleports you randomly on a small scale range (%d)
		The range will increase with the Magic stat]]):format(10 + self:combatSpellpower(0.1))
	end,
}

newTalent{
	name = "Controlled Teleport",
	type = {"spell/conveyance",4},
	mode = "passive",
	points = 2,
	require = { stat = { mag=50 }, talent = {Talents.T_TELEPORT}, },
	info = function(self)
		return ([[Allows teleport spells to specify a target area. You will blink in this radius randomly.
		The radius (%d) of the target area decreases with Magic stat]]):format(5 - self:combatSpellpower(0.03))
	end,
}

newTalent{
	name = "Targeted Teleport",
	type = {"spell/conveyance",4},
	mode = "passive",
	require = { stat = { mag=50 }, talent = {Talents.T_TELEPORT}, },
	info = function(self)
		return ([[Allows teleport spells to specify the affected target, either you, allies or foes.]])
	end,
}

newTalent{
	name = "Probability Travel",
	type = {"spell/conveyance",4},
	mode = "sustained",
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
	require = { stat = { mag=34 }, level=25 },
	info = function(self)
		return ([[When you hit a solid surface this spell tears down the laws of probability to make you instantly appear on the other side.]])
	end,
}

newTalent{
	name = "Recall",
	type = {"spell/conveyance",3},
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
	require = { stat = { mag=34 }, },
	info = function(self)
		return ([[Recalls you to your home town after a few turns.]])
	end,
}

newTalent{
	name = "Telekinesis",
	type = {"spell/conveyance",4},
	mode = "passive",
	require = { stat = { mag=50 }, },
	info = function(self)
		return ([[Recall can now target an object on the floor to teleport it to your inventory.]])
	end,
}

newTalent{
	name = "Imperious Summon",
	type = {"spell/conveyance",4},
	mode = "passive",
	require = { stat = { mag=50 }, },
	info = function(self)
		return ([[Recall can now target your foes to teleport one to you.]])
	end,
}
