-- Load other misc things
load("/data/talents/misc/npcs.lua")
load("/data/talents/misc/random.lua")

-- race & classes
newTalentType{ type="base/class", name = "class", hide = true, description = "The basic talents defining a class." }
newTalentType{ type="base/race", name = "race", hide = true, description = "The various racial bonuses a character can have." }

newTalent{
	name = "Mana Pool",
	type = {"base/class", 1},
	info = "Allows you to have a mana pool. Mana is used to cast all spells.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Stamina Pool",
	type = {"base/class", 1},
	info = "Allows you to have a stamina pool. Stamina is used to activate special combat attacks.",
	mode = "passive",
	hide = true,
}

newTalent{
	name = "Improved Health I",
	type = {"base/race", 1},
	info = "Improves the number of health points per levels.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Improved Health II",
	type = {"base/race", 1},
	info = "Improves the number of health points per levels.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Improved Health III",
	type = {"base/race", 1},
	info = "Improves the number of health points per levels.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Decreased Health I",
	type = {"base/race", 1},
	info = "Improves the number of health points per levels.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Decreased Health II",
	type = {"base/race", 1},
	info = "Improves the number of health points per levels.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Decreased Health III",
	type = {"base/race", 1},
	info = "Improves the number of health points per levels.",
	mode = "passive",
	hide = true,
}

-- Dunadan's power, a "weak" regeneration
newTalent{
	short_name = "DUNADAN_HEAL",
	name = "King's Gift",
	type = {"base/class", 1},
	cooldown = 50,
	action = function(self, t)
		self:setEffect(self.EFF_REGENERATION, 10, {power=5 + self:getWil() * 0.5})
		return true
	end,
	info = function(self)
		return ([[Call upon the gift of the Kings to regenerate your body for %d life every turns for 10 turns.
		The life healed will increase with the Willpower stat]]):format(5 + self:getWil() * 0.5)
	end,
}

-- Nandor's power, a temporary speedup
newTalent{
	short_name = "NANDOR_SPEED",
	name = "Grace of the Eldar",
	type = {"base/class", 1},
	cooldown = 50,
	action = function(self, t)
		self:setEffect(self.EFF_SPEED, 8, {power=0.20 + self:getDex() / 80})
		return true
	end,
	info = function(self)
		return ([[Call upon the grace of the Eldar to increase your general speed by %d%% for 8 turns.
		The speed will increase with the Dexterity stat]]):format((0.20 + self:getDex() / 80) * 100)
	end,
}

-- Dwarf's power, a temporary stone shield
newTalent{
	short_name = "DWARF_RESILIENCE",
	name = "Resilience of the Dwarves",
	type = {"base/class", 1},
	cooldown = 50,
	action = function(self, t)
		self:setEffect(self.EFF_DWARVEN_RESILIENCE, 8, {
			armor=5 + self:getCon() / 5,
			physical=10 + self:getCon() / 5,
			spell=10 + self:getCon() / 5,
		})
		return true
	end,
	info = function(self)
		return ([[Call legendary resilience of the Dwarven race to increase your armor(+%d), spell(+%d) and physical(+%d) resistances for 8 turns.
		The bonus will increase with the Constitution stat]]):format(5 + self:getCon() / 5, 10 + self:getCon() / 5, 10 + self:getCon() / 5)
	end,
}
