-- Spells
newTalentType{ type="spell/arcane", name = "arcane", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ type="spell/fire", name = "fire", description = "Harness the power of fire to burn your foes to ashes." }
newTalentType{ type="spell/earth", name = "earth", description = "Harness the power of the earth to protect and destroy." }
newTalentType{ type="spell/cold", name = "cold", description = "Harness the power of winter to shatter your foes." }
newTalentType{ type="spell/air", name = "air", description = "Harness the power of the air to fry your foes." }
newTalentType{ type="spell/conveyance", name = "conveyance", description = "Conveyance is the school of travel. It allows you to travel faster and to track others." }

newTalent{
	name = "Manathrust",
	type = {"spell/arcane", 1},
	mana = 10,
	tactical = {
		ATTACK = 10,
	},
	action = function(self)
		local t = {type="bolt", range=20}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		self:project(t, x, y, DamageType.ARCANE, 10 + self:getMag())
		return true
	end,
	require = { stat = { mag=10 }, },
	info = function(self)
		return ([[Conjures up mana into a powerful bolt doing %0.2f arcane damage
		The damage will increase with the Magic stat]]):format(10 + self:getMag())
	end,
}
newTalent{
	name = "Disruption Shield",
	type = {"spell/arcane",2},
	mode = "sustained",
	sustain_mana = 60,
	tactical = {
		DEFEND = 10,
	},
	action = function(self)
		return true
	end,
	require = { stat = { mag=12 }, },
	info = function(self)
		return ([[Uses mana instead of life to take damage
		The damage to mana ratio increases with the Magic stat]]):format(10 + self:getMag())
	end,
}

newTalent{
	name = "Globe of Light",
	type = {"spell/fire",1},
	mana = 5,
	tactical = {
		ATTACKAREA = 3,
	},
	action = function(self)
		local t = {type="ball", range=0, friendlyfire=false, radius=5 + self:getMag(10)}
		self:project(t, self.x, self.y, DamageType.LIGHT, 1)
		return true
	end,
	require = { stat = { mag=10 }, },
	info = function(self)
		return ([[Creates a globe of pure light with a radius of %d that illuminates the area.
		The radius will increase with the Magic stat]]):format(5 + self:getMag(10))
	end,
}

newTalent{
	name = "Fireflash",
	type = {"spell/fire",2},
	mana = 35,
	cooldown = 6,
	tactical = {
		ATTACKAREA = 10,
	},
	action = function(self)
		local t = {type="ball", range=15, radius=math.min(6, 3 + self:getMag(6))}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		self:project(t, x, y, DamageType.FIRE, 28 + self:getMag(70))
		return true
	end,
	require = { stat = { mag=16 }, },
	info = function(self)
		return ([[Conjures up a flash of fire doing %0.2f fire damage in a radius of %d.
		Cooldown: 6 turns
		The damage will increase with the Magic stat]]):format(8 + self:getMag(70), math.min(6, 3 + self:getMag(6)))
	end,
}

newTalent{
	name = "Blink",
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
	require = { stat = { mag=16 }, },
	info = function(self)
		return ([[Teleports you randomly on a small scale range (%d)
		The range will increase with the Magic stat]]):format(10 + self:getMag(10))
	end,
}

newTalent{
	name = "Teleport Control",
	type = {"spell/conveyance",2},
	require = { stat = { mag=38 }, },
	info = function(self)
		return ([[Allows teleport spells to specify a target area. You will blink in this radius randomly.
		The radius (%d) of the target area decreases with Magic stat]]):format(5 - self:getMag(4))
	end,
}


newTalent{
	name = "Noxious Cloud",
	type = {"spell/earth",1},
	mana = 45,
	cooldown = 8,
	tactical = {
		ATTACKAREA = 10,
	},
	action = function(self)
		local duration = 5 + self:getMag(10)
		local radius = 3
		local t = {type="ball", range=15, radius=math.min(6, 3 + self:getMag(6))}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		x, y = game.target:pointAtRange(self.x, self.y, x, y, 15)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.NATURE, 4 + self:getMag(30),
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=30, color_bg=180, color_bb=60}
		)
		return true
	end,
	require = { stat = { mag=16 }, },
	info = function(self)
		return ([[Noxious fumes raises from the ground doing %0.2f nature damage in a radius of 3 each turns for %d turns.
		Cooldown: 8 turns
		The damage and duration will increase with the Magic stat]]):format(4 + self:getMag(30), 5 + self:getMag(10))
	end,
}
