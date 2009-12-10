newTalent{
	name = "Phase Door",
	type = {"spell/conveyance",1},
	message = "@Source@ blinks.",
	mana = 15,
	cooldown = 9,
	tactical = {
		ESCAPE = 4,
	},
	action = function(self)
		local x, y = self.x, self.y
		if self:knowTalent(self.T_TELEPORT_CONTROL) then
			x, y = self:getTarget{type="ball", range=10 + self:getMag(10), radius=5 - self:getMag(4)}
			if not x then return nil end
			-- Target code doesnot restrict the target coordinates to the range, it lets the poject function do it
			-- but we cant ...
			x, y = game.target:pointAtRange(self.x, self.y, x, y, 10 + self:getMag(10))
			self:teleportRandom(x, y, 5 - self:getMag(4))
		else
			self:teleportRandom(x, y, 10 + self:getMag(10))
		end
		return true
	end,
	require = { stat = { mag=12 }, },
	info = function(self)
		return ([[Teleports you randomly on a small scale range (%d)
		The range will increase with the Magic stat]]):format(10 + self:getMag(10))
	end,
}

newTalent{
	name = "Teleport Control",
	type = {"spell/conveyance",2},
	mode = "passive",
	require = { stat = { mag=38 }, },
	info = function(self)
		return ([[Allows teleport spells to specify a target area. You will blink in this radius randomly.
		The radius (%d) of the target area decreases with Magic stat]]):format(5 - self:getMag(4))
	end,
}
