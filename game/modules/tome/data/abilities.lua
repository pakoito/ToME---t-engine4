-- Mana spells
newAbilityType{ type="spell/mana", name = "mana" }

newAbility{
	name = "Manathrust",
	type = "spell/mana",
	mana = 15,
	tactical = {
		ATTACK = 10,
	},
	action = function(user)
		user:project(game.target.x, game.target.y, Damages.MANA, 10 + user:getMag())
		return true
	end,
	require = { stat = { mag=12 }, },
	info = function(user)
		return ([[Conjures up mana into a powerful bolt doing %d",
		The damage is irresistible and will increase with magic stat]]):format(10 + user:getMag())
	end
}
