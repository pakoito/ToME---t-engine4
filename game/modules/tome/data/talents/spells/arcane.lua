newTalent{
	name = "Manathrust",
	type = {"spell/arcane", 1},
	mana = 10,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	action = function(self)
		local t = {type="bolt", range=20}
		if self:knowTalent(Talents.T_ARCANE_LANCE) then t.type = "beam" end
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		self:project(t, x, y, DamageType.ARCANE, self:spellCrit(10 + self:combatSpellpower()))
		return true
	end,
	require = { stat = { mag=10 }, },
	info = function(self)
		return ([[Conjures up mana into a powerful bolt doing %0.2f arcane damage
		The damage will increase with the Magic stat]]):format(10 + self:combatSpellpower())
	end,
}
newTalent{
	name = "Arcane Lance",
	type = {"spell/arcane", 2},
	mode = "passive",
	require = { stat = { mag=24 }, talent = { Talents.T_MANATHRUST }, },
	info = function(self)
		return [[Manathrust is now a beam and hits all targets in line.]]
	end,
}

newTalent{
	name = "Manaflow",
	type = {"spell/arcane", 2},
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
	require = { stat = { mag=34 }, },
	info = function(self)
		return ([[Engulf yourself into a surge of mana, quickly restoring %d mana every turns for 10 turns.
		The mana restored will increase with the Magic stat]]):format(5 + self:combatSpellpower(0.3))
	end,
}

newTalent{
	name = "Arcane Power",
	type = {"spell/arcane", 3},
	mode = "passive",
	require = { stat = { mag=40 }, },
	on_learn = function(self)
		self.combat_spellpower = self.combat_spellpower + 10
	end,
	on_unlearn = function(self)
		self.combat_spellpower = self.combat_spellpower - 10
	end,
	info = function(self)
		return [[Your mastery of magic allows your to permanently increase your spellpower by 10.]]
	end,
}

newTalent{
	name = "Disruption Shield",
	type = {"spell/arcane",4},
	mode = "sustained",
	sustain_mana = 150,
	tactical = {
		DEFEND = 10,
	},
	action = function(self)
		return true
	end,
	require = { stat = { mag=60 }, level=40 },
	info = function(self)
		return ([[Uses mana instead of life to take damage
		The damage to mana ratio increases with the Magic stat]]):format(10 + self:combatSpellpower())
	end,
}
