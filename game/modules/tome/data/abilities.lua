-- Mana spells
newAbilityType{ type="spell/arcane", name = "arcane" }
newAbilityType{ type="spell/fire", name = "fire" }
newAbilityType{ type="spell/earth", name = "earth" }
newAbilityType{ type="spell/cold", name = "cold" }
newAbilityType{ type="spell/lightning", name = "lightning" }
newAbilityType{ type="spell/conveyance", name = "conveyance" }

newAbility{
	name = "Manathrust",
	type = "spell/arcane",
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
	require = { stat = { mag=12 }, },
	info = function(self)
		return ([[Conjures up mana into a powerful bolt doing %0.2f arcane damage",
		The damage will increase with the Magic stat]]):format(10 + self:getMag())
	end,
}

newAbility{
	name = "Fireflash",
	type = "spell/fire",
	mana = 45,
	tactical = {
		ATTACKAREA = 10,
	},
	action = function(self)
		local t = {type="ball", range=15, radius=math.min(6, 3 + self:getMag(6))}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		self:project(t, x, y, DamageType.FIRE, 8 + self:getMag(70))
		return true
	end,
	require = { stat = { mag=16 }, },
	info = function(self)
		return ([[Conjures up a flash of fire doing %0.2f fire damage in a radius of %d",
		The damage will increase with the Magic stat]]):format(8 + self:getMag(70), math.min(6, 3 + self:getMag(6)))
	end,
}

newAbility{
	name = "Phase Door",
	type = "spell/conveyance",
	message = "@Source@ blinks.",
	mana = 15,
	tactical = {
		ESCAPE = 4,
	},
	action = function(self)
		self:teleportRandom(10 + self:getMag(10))
		return true
	end,
	require = { stat = { mag=16 }, },
	info = function(self)
		return ([[Teleports you randomly on a small scale range (%d)",
		The range will increase with the Magic stat]]):format(10 + self:getMag(10))
	end,
}
