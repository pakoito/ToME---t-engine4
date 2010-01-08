newTalent{
	name = "Stone Skin",
	type = {"spell/earth", 1},
	mode = "sustained",
	points = 5,
	sustain_mana = 45,
	cooldown = 10,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		local power = 4 + self:combatSpellpower(0.03) * self:getTalentLevel(t)
		return {
			armor = self:addTemporaryValue("combat_armor", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_armor", p.armor)
		return true
	end,
	require = { stat = { mag=14 }, },
	info = function(self, t)
		return ([[The caster skin grows as hard as stone, granting %d bonus to armor.
		The bonus to armor will increase with the Magic stat]]):format(4 + self:combatSpellpower(0.03) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Dig",
	type = {"spell/earth",2},
	points = 5,
	mana = 40,
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		for i = 1, self:getTalentLevelRaw(t) do
			self:project(tg, x, y, DamageType.DIG, 1)
		end
		return true
	end,
	require = { stat = { mag=24 } },
	info = function(self, t)
		return ([[Digs up to %d grids into walls/trees/...]]):format(self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Strike",
	type = {"spell/earth",3},
	points = 5,
	mana = 18,
	cooldown = 6,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SPELLKNOCKBACK, self:spellCrit(8 + self:combatSpellpower(0.15) * self:getTalentLevel(t)))
		return true
	end,
	require = { stat = { mag=24 }, },
	info = function(self, t)
		return ([[Conjures up a fist of stone doing %0.2f physical damage and knocking the target back.
		The damage will increase with the Magic stat]]):format(8 + self:combatSpellpower(0.15) * self:getTalentLevel(t))
	end,
}
