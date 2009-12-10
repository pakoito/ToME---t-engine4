newTalent{
	name = "Stone Skin",
	type = {"spell/earth", 1},
	mode = "sustained",
	mana = 45,
	cooldown = 10,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self)
		local power = 1 + self:getMag(15)
		self.combat.armor = self.combat.armor + power
		return {power=power}
	end,
	deactivate = function(self, p)
		self.combat.armor = self.combat.armor - p.power
	end,
	require = { stat = { mag=14 }, },
	info = function(self)
		return ([[The caster skin grows as hard as stone, granting %d bonus to armor.
		The bonus to armor will increase with the Magic stat]]):format(1 + self:getMag(15))
	end,
}
