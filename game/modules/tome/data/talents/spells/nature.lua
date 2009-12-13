newTalent{
	name = "Regeneration",
	type = {"spell/nature", 1},
	mana = 30,
	cooldown = 10,
	tactical = {
		HEAL = 10,
	},
	action = function(self)
		self:setEffect(self.EFF_REGENERATION, 10, {power=5 + self:combatSpellpower(0.35)})
		return true
	end,
	require = { stat = { mag=10 }, },
	info = function(self)
		return ([[Call upon the forces of nature to regenerate your body for %d life every turns for 10 turns.
		The life healed will increase with the Magic stat]]):format(5 + self:combatSpellpower(0.35))
	end,
}

newTalent{
	name = "Heal",
	type = {"spell/nature", 2},
	mana = 60,
	cooldown = 10,
	tactical = {
		HEAL = 10,
	},
	action = function(self)
		self:heal(10 + self:combatSpellpower(2), self)
		return true
	end,
	require = { stat = { mag=20 }, },
	info = function(self)
		return ([[Call upon the forces of nature to heal your body for %d life.
		The life healed will increase with the Magic stat]]):format(10 + self:combatSpellpower(2))
	end,
}
