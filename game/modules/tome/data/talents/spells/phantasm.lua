newTalent{
	name = "Illuminate",
	type = {"spell/phantasm",1},
	require = spells_req1,
	points = 5,
	mana = 5,
	cooldown = 14,
	action = function(self, t)
		local tg = {type="ball", range=0, friendlyfire=false, radius=5 + self:getTalentLevel(t)}
		self:project(tg, self.x, self.y, DamageType.LIGHT, 1)
		if self:getTalentLevel(t) >= 3 then
			self:project(tg, self.x, self.y, DamageType.BLIND, 3 + self:getTalentLevel(t))
		end
		return true
	end,
	info = function(self, t)
		return ([[Creates a globe of pure light with a radius of %d that illuminates the area.
		At level 3 it also blinds all who see it (except the caster).
		The radius will increase with the Magic stat]]):format(5 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Blur Sight",
	type = {"spell/phantasm", 2},
	mode = "sustained",
	require = spells_req2,
	points = 5,
	sustain_mana = 60,
	cooldown = 10,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		local power = 4 + self:combatSpellpower(0.04) * self:getTalentLevel(t)
		return {
			def = self:addTemporaryValue("combat_def", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_def", p.def)
		return true
	end,
	info = function(self, t)
		return ([[The caster's image blurs, making her harder to hit, granting %d bonus to defense.
		The bonus will increase with the Magic stat]]):format(4 + self:combatSpellpower(0.04) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Phantasmal Shield",
	type = {"spell/phantasm", 3},
	mode = "sustained",
	require = spells_req3,
	points = 5,
	sustain_mana = 100,
	cooldown = 10,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		local power = 10 + self:combatSpellpower(0.06) * self:getTalentLevel(t)
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.ARCANE]=power}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		return true
	end,
	info = function(self, t)
		return ([[The caster surrounds herself with a phantasmal shield. If hit in melee the shield will deal %d arcane damage to the attacker.
		The damage will increase with the Magic stat]]):format(10 + self:combatSpellpower(0.06) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Invisibility",
	type = {"spell/phantasm", 4},
	mode = "sustained",
	require = spells_req4,
	points = 5,
	sustain_mana = 200,
	cooldown = 30,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		local power = 4 + self:combatSpellpower(0.04) * self:getTalentLevel(t)
		return {
			invisible = self:addTemporaryValue("invisible", power),
			drain = self:addTemporaryValue("mana_regen", -5),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("invisible", p.invisible)
		self:removeTemporaryValue("mana_regen", p.drain)
		return true
	end,
	info = function(self, t)
		return ([[The caster fades from sight, granting %d bonus to invisibility.
		This powerful spell constantly drains your mana while active.
		The bonus will increase with the Magic stat]]):format(4 + self:combatSpellpower(0.04) * self:getTalentLevel(t))
	end,
}
