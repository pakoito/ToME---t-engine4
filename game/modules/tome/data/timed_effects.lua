newEffect{
	name = "CUT",
	desc = "Bleeding",
	type = "physical",
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target# starts to bleed.", "+Bleeds" end,
	on_lose = function(self, err) return "#Target# stops bleeding.", "-Bleeds" end,
	on_timeout = function(self, eff)
		self:takeHit(eff.power, self)
	end,
}

newEffect{
	name = "MANAFLOW",
	desc = "Surging mana",
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# starts to surge mana.", "+Manaflow" end,
	on_lose = function(self, err) return "#Target# stops surging mana.", "-Manaflow" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("mana_regen", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("mana_regen", eff.tmpid)
	end,
}

newEffect{
	name = "REGENERATION",
	desc = "Regeneration",
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# starts to regenerating heath quickly.", "+Regen" end,
	on_lose = function(self, err) return "#Target# stops regenerating health quickly.", "-Regen" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("life_regen", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("life_regen", eff.tmpid)
	end,
}

newEffect{
	name = "BURNING",
	desc = "Burning",
	type = "magical",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is on fire!", "+Burn" end,
	on_lose = function(self, err) return "#Target# stops burning.", "-Burn" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.FIRE, eff.power)
	end,
}
