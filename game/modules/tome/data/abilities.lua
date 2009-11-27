-- Mana spells
newAbilityType{ type="spell/mana", name = "mana" }

newAbility{
	name = "Manathrust",
	type = "spell/mana",
	mana = 15,
	tactical = {
		ATTACK = 10,
	},
	action = function(self)
		self:project(game.target.target.x, game.target.target.y, DamageType.MANA, 10 + self:getMag())
		return true
	end,
	require = { stat = { mag=12 }, },
	info = function(self)
		return ([[Conjures up mana into a powerful bolt doing %d",
		The damage is irresistible and will increase with magic stat]]):format(10 + self:getMag())
	end
}
