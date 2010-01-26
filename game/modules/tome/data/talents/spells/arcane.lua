newTalent{
	name = "Manathrust",
	type = {"spell/arcane", 1},
	require = spells_req1,
	points = 5,
	mana = 10,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		if self:getTalentLevel(t) >= 3 then tg.type = "beam" end
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ARCANE, self:spellCrit(20 + self:combatSpellpower(0.5) * self:getTalentLevel(t)), {type="manathrust"})
		return true
	end,
	info = function(self, t)
		return ([[Conjures up mana into a powerful bolt doing %0.2f arcane damage
		At level 3 it becomes a beam.
		The damage will increase with the Magic stat]]):format(20 + self:combatSpellpower(0.5) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Manaflow",
	type = {"spell/arcane", 2},
	require = spells_req2,
	points = 5,
	mana = 0,
	cooldown = 300,
	tactical = {
		MANA = 20,
	},
	action = function(self, t)
		if not self:hasEffect(self.EFF_MANAFLOW) then
			self:setEffect(self.EFF_MANAFLOW, 10, {power=5+self:combatSpellpower(0.06) * self:getTalentLevel(t)})
		end
		return true
	end,
	info = function(self, t)
		return ([[Engulf yourself into a surge of mana, quickly restoring %d mana every turns for 10 turns.
		The mana restored will increase with the Magic stat]]):format(5 + self:combatSpellpower(0.06) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Arcane Power",
	type = {"spell/arcane", 3},
	mode = "passive",
	require = spells_req3,
	points = 5,
	on_learn = function(self, t)
		self.combat_spellpower = self.combat_spellpower + 5
	end,
	on_unlearn = function(self, t)
		self.combat_spellpower = self.combat_spellpower - 5
	end,
	info = function(self, t)
		return [[Your mastery of magic allows your to permanently increase your spellpower by 5.]]
	end,
}

newTalent{
	name = "Disruption Shield",
	type = {"spell/arcane",4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	sustain_mana = 150,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		local power = math.max(0.8, 3 - (self:combatSpellpower(1) * self:getTalentLevel(t)) / 280)
		self.disruption_shield_absorb = 0
		return {
			shield = self:addTemporaryValue("disruption_shield", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("disruption_shield", p.shield)
		self.disruption_shield_absorb = nil
		return true
	end,
	info = function(self, t)
		return ([[Uses mana instead of life to take damage. Uses %0.2f mana per damage taken.
		If your mana is brought too low by the shield it will de-activate and the chain reaction will release a deadly arcane explosion of the amount of damage absorbed.
		The damage to mana ratio increases with the Magic stat]]):format(math.max(0.8, 3 - (self:combatSpellpower(1) * self:getTalentLevel(t)) / 280))
	end,
}
