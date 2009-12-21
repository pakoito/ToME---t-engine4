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
		local power = 1 + self:combatSpellpower(0.15)
		self.combat.armor = self.combat.armor + power
		return {power=power}
	end,
	deactivate = function(self, p)
		self.combat.armor = self.combat.armor - p.power
	end,
	require = { stat = { mag=14 }, },
	info = function(self)
		return ([[The caster skin grows as hard as stone, granting %d bonus to armor.
		The bonus to armor will increase with the Magic stat]]):format(1 + self:combatSpellpower(0.15))
	end,
}

newTalent{
	name = "Strike",
	type = {"spell/earth",2},
	mana = 18,
	cooldown = 6,
	tactical = {
		ATTACK = 10,
	},
	action = function(self)
		local t = {type="bolt", range=20}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		self:project(t, x, y, DamageType.SPELLKNOCKBACK, self:spellCrit(8 + self:combatSpellpower(0.6)))
		return true
	end,
	require = { stat = { mag=24 }, level=5 },
	info = function(self)
		return ([[Conjures up a fist of stone doing %0.2f physical damage and knocking the target back.
		The damage will increase with the Magic stat]]):format(8 + self:combatSpellpower(0.6))
	end,
}
