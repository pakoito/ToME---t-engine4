local Stats = require "engine.interface.ActorStats"

newEffect{
	name = "CUT",
	desc = "Bleeding",
	type = "physical",
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target# starts to bleed.", "+Bleeds" end,
	on_lose = function(self, err) return "#Target# stops bleeding.", "-Bleeds" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
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

newEffect{
	name = "POISONED",
	desc = "Poisoned",
	type = "magical",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is poisoned!", "+Poison" end,
	on_lose = function(self, err) return "#Target# stops beign poisoned.", "-Poison" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
	end,
}

newEffect{
	name = "FROZEN",
	desc = "Frozen",
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is frozen!" end,
	on_lose = function(self, err) return "#Target# warms up.", "-Frozen" end,
	activate = function(self, eff)
		-- Change color
		eff.old_r = self.color_r
		eff.old_g = self.color_g
		eff.old_b = self.color_b
		self.color_r = 0
		self.color_g = 255
		self.color_b = 155
		game.level.map:updateMap(self.x, self.y)

		-- Frozen, cannot act
		self.energy.value = 0
	end,
	on_timeout = function(self, eff)
		-- Frozen, cannot act
		self.energy.value = 0
	end,
	deactivate = function(self, eff)
		self.color_r = eff.old_r
		self.color_g = eff.old_g
		self.color_b = eff.old_b
	end,
}

newEffect{
	name = "BURNING_SHOCK",
	desc = "Burning Shock",
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is stunned by the burning flame!", "+Burning Shock" end,
	on_lose = function(self, err) return "#Target# is not stunned anymore.", "-Burning Shock" end,
	activate = function(self, eff)
		self.energy.value = 0
	end,
	on_timeout = function(self, eff)
		self.energy.value = 0
		DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.FIRE, eff.power)
	end,
}

newEffect{
	name = "STUNNED",
	desc = "Stunned",
	type = "physical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is stunned!", "+Stunned" end,
	on_lose = function(self, err) return "#Target# is not stunned anymore.", "-Stunned" end,
	activate = function(self, eff)
		-- Frozen, cannot act
		self.energy.value = 0
	end,
	on_timeout = function(self, eff)
		-- Frozen, cannot act
		self.energy.value = 0
	end,
}

newEffect{
	name = "SPEED",
	desc = "Speed",
	type = "magical",
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# speeds up.", "+Fast" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Fast" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("energy", {mod=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("energy", eff.tmpid)
	end,
}

newEffect{
	name = "SLOW",
	desc = "Slow",
	type = "magical",
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# slows down.", "+Slow" end,
	on_lose = function(self, err) return "#Target# speeds up.", "-Slow" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("energy", {mod=-eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("energy", eff.tmpid)
	end,
}

newEffect{
	name = "INVISIBILITY",
	desc = "Invisibility",
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# vanishes from sight.", "+Invis" end,
	on_lose = function(self, err) return "#Target# is not more invisible.", "-Invis" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("invisible", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invisible", eff.tmpid)
	end,
}

newEffect{
	name = "SEE_INVISIBLE",
	desc = "See Invisible",
	type = "magical",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#'s eyes tingle." end,
	on_lose = function(self, err) return "#Target#'s eyes tingle no more." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("see_invisible", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("see_invisible", eff.tmpid)
	end,
}

newEffect{
	name = "BLINDED",
	desc = "Blinded",
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# loses sight!.", "+Blind" end,
	on_lose = function(self, err) return "#Target# recovers sight.", "-Blind" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("blind", 1)
		if self.player then game.level.map:redisplay() end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("blind", eff.tmpid)
		if self.player then game.level.map:redisplay() end
	end,
}

newEffect{
	name = "CONFUSED",
	desc = "Confused",
	type = "magical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# wanders around!.", "+Confused" end,
	on_lose = function(self, err) return "#Target# seems more focused.", "-Confused" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("confused", eff.tmpid)
	end,
}

newEffect{
	name = "DWARVEN_RESILIENCE",
	desc = "Dwarven Resilience",
	type = "physical",
	status = "beneficial",
	parameters = { armor=10, spell=10, physical=10 },
	on_gain = function(self, err) return "#Target#'s skin turns to stone." end,
	on_lose = function(self, err) return "#Target# returns to normal." end,
	activate = function(self, eff)
		eff.aid = self:addTemporaryValue("combat_armor", eff.armor)
		eff.pid = self:addTemporaryValue("combat_physresist", eff.physical)
		eff.sid = self:addTemporaryValue("combat_spellresist", eff.spell)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_armor", eff.aid)
		self:removeTemporaryValue("combat_physresist", eff.pid)
		self:removeTemporaryValue("combat_spellresist", eff.sid)
	end,
}

newEffect{
	name = "HOBBIT_LUCK",
	desc = "Hobbit's Luck",
	type = "physical",
	status = "beneficial",
	parameters = { spell=10, physical=10 },
	on_gain = function(self, err) return "#Target# seems more aware." end,
	on_lose = function(self, err) return "#Target# awareness returns to normal." end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("combat_physcrit", eff.physical)
		eff.sid = self:addTemporaryValue("combat_spellcrit", eff.spell)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_physcrit", eff.pid)
		self:removeTemporaryValue("combat_spellcrit", eff.sid)
	end,
}

newEffect{
	name = "TIME_PRISON",
	desc = "Time Prison",
	type = "other",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is removed from time!", "+Out of Time" end,
	on_lose = function(self, err) return "#Target# is into normal time.", "-Out of Time" end,
	activate = function(self, eff)
		eff.iid = self:addTemporaryValue("invulnerable", 1)
		self.energy.value = 0
	end,
	on_timeout = function(self, eff)
		self.energy.value = 0
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invulnerable", eff.iid)
	end,
}

newEffect{
	name = "SENSE",
	desc = "Sensing",
	type = "magical",
	status = "beneficial",
	parameters = { range=10, actor=1, object=0, trap=0 },
	activate = function(self, eff)
		eff.rid = self:addTemporaryValue("detect_range", eff.range)
		eff.aid = self:addTemporaryValue("detect_actor", eff.actor)
		eff.oid = self:addTemporaryValue("detect_object", eff.object)
		eff.tid = self:addTemporaryValue("detect_trap", eff.trap)
		game.level.map.changed = true
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("detect_range", eff.rid)
		self:removeTemporaryValue("detect_actor", eff.aid)
		self:removeTemporaryValue("detect_object", eff.oid)
		self:removeTemporaryValue("detect_trap", eff.tid)
	end,
}

newEffect{
	name = "ALL_STAT",
	desc = "All stats increase",
	type = "magical",
	status = "beneficial",
	parameters = { power=1 },
	activate = function(self, eff)
		eff.stat = self:addTemporaryValue("stats",
		{
			[Stats.STAT_STR] = eff.power,
			[Stats.STAT_DEX] = eff.power,
			[Stats.STAT_MAG] = eff.power,
			[Stats.STAT_WIL] = eff.power,
			[Stats.STAT_CUN] = eff.power,
			[Stats.STAT_CON] = eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stats", eff.stat)
	end,
}

newEffect{
	name = "TIME_SHIELD",
	desc = "Time Shield",
	type = "time",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "The very fabric of time alters around #target#.", "+Time Shield" end,
	on_lose = function(self, err) return "The fabric of time around #target# stabilizes to normal.", "-Time Shield" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("time_shield", eff.power)
		--- Warning there can be only one time shield active at once for an actor
		self.time_shield_absorb = eff.power
	end,
	deactivate = function(self, eff)
		-- Time shield ends, setup a dot if needed
		if eff.power - self.time_shield_absorb > 0 then
			print("Time shield dot", eff.power - self.time_shield_absorb, (eff.power - self.time_shield_absorb) / 5)
			self:setEffect(self.EFF_TIME_DOT, 5, {power=(eff.power - self.time_shield_absorb) / 5})
		end

		self:removeTemporaryValue("time_shield", eff.tmpid)
		self.time_shield_absorb = nil
	end,
}

newEffect{
	name = "TIME_DOT",
	desc = "Time Shield Backfire",
	type = "time",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "The powerfull time altering energies come crashing down on #target#.", "+Time Shield Backfire" end,
	on_lose = function(self, err) return "The fabric of time around #target# returns to normal.", "-Time Shield Backfire" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.ARCANE).projector(self, self.x, self.y, DamageType.ARCANE, eff.power)
	end,
}

newEffect{
	name = "SUNDER_ARMOUR",
	desc = "Sunder Armour",
	type = "physical",
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_armor", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_armor", eff.tmpid)
	end,
}

newEffect{
	name = "SUNDER_ARMS",
	desc = "Sunder Arms",
	type = "physical",
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_atk", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.tmpid)
	end,
}

newEffect{
	name = "PINNED",
	desc = "Pinned to the ground",
	type = "physical",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is pinned to the ground.", "+Pinned" end,
	on_lose = function(self, err) return "#Target# is no longer pinned.", "-Pinned" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}
