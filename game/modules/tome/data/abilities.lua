-- Mana spells
newAbilityType{ type="spell/arcane", name = "arcane" }

newAbility{
	name = "Manathrust",
	type = "spell/arcane",
	mana = 15,
	tactical = {
		ATTACK = 10,
	},
	action = function(self)
		local t = {type="ball", range=20, radius=4}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		self:project(t, x, y, DamageType.ARCANE, 10 + self:getMag())
		return true
	end,
	require = { stat = { mag=12 }, },
	info = function(self)
		return ([[Conjures up mana into a powerful bolt doing %0.2f arcane damage",
		The damage will increase with the Magic stat]]):format(10 + self:getMag())
	end
}
