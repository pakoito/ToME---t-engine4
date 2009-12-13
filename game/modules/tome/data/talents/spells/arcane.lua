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
		self:project(t, x, y, DamageType.ARCANE, 10 + self:combatSpellpower())
		return true
	end,
	require = { stat = { mag=10 }, },
	info = function(self)
		return ([[Conjures up mana into a powerful bolt doing %0.2f arcane damage
		The damage will increase with the Magic stat]]):format(10 + self:combatSpellpower())
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
	require = { stat = { mag=50 }, },
	info = function(self)
		return ([[Uses mana instead of life to take damage
		The damage to mana ratio increases with the Magic stat]]):format(10 + self:combatSpellpower())
	end,
}
newTalent{
	name = "Manaflow",
	type = {"spell/arcane", 3},
	mana = 0,
	cooldown = 300,
	tactical = {
		MANA = 20,
	},
	action = function(self)
		if not self:hasEffect(self.EFF_MANAFLOW) then
			self:setEffect(self.EFF_MANAFLOW, 10, {power=5+self:combatSpellpower(0.3)})
		end
		return true
	end,
	require = { stat = { mag=60 }, },
	info = function(self)
		return ([[Engulf yourself into a surge of mana, quickly restoring %d mana every turns for 10 turns.
		The mana restored will increase with the Magic stat]]):format(5 + self:combatSpellpower(0.3))
	end,
}
