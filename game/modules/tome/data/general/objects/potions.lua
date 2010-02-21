newEntity{
	define_as = "BASE_POTION",
	type = "potion", subtype="potion",
	unided_name = "potion", id_by_type = true,
	display = "!", color=colors.WHITE, image="object/potion-0x0.png",
	encumber = 0.2,
	stacking = true,
	acid_destroy = 20,
	desc = [[Magical potions can have wildly different effects, from healing to killing you, beware! Most of them function better with a high Magic score]],
	egos = "/data/general/objects/egos/potions.lua", egos_chance = resolvers.mbonus(10, 5),
}

-------------------------------------------------------
-- Healing
-------------------------------------------------------
newEntity{ base = "BASE_POTION",
	name = "potion of lesser healing",
	color = colors.LIGHT_RED, image="object/potion-0x3.png",
	level_range = {1, 20},
	rarity = 3,
	cost = 3,

	use_simple = { name="heal some life", use = function(self, who)
		who:heal(40 + who:getMag())
		game.logSeen(who, "%s quaffs a %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end}
}

newEntity{ base = "BASE_POTION",
	name = "potion of healing",
	color = colors.LIGHT_RED, image="object/potion-0x3.png",
	level_range = {15, 35},
	rarity = 4,
	cost = 5,

	use_simple = { name="heal a good part of your life", use = function(self, who)
		who:heal(140 + who:getMag())
		game.logSeen(who, "%s quaffs a %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end}
}

newEntity{ base = "BASE_POTION",
	name = "potion of greater healing",
	color = colors.LIGHT_RED, image="object/potion-0x3.png",
	level_range = {30, 50},
	rarity = 5,
	cost = 7,

	use_simple = { name="heal a lot", use = function(self, who)
		who:heal(240 + who:getMag())
		game.logSeen(who, "%s quaffs a %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end}
}

newEntity{ base = "BASE_POTION",
	name = "potion of full healing",
	color = colors.LIGHT_RED, image="object/potion-0x3.png",
	level_range = {45, 50},
	rarity = 14,
	cost = 50,

	use_simple = { name="fully heal", use = function(self, who)
		who:heal(1000000)
		game.logSeen(who, "%s quaffs a %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end}
}

-------------------------------------------------------
-- Mana
-------------------------------------------------------
newEntity{ base = "BASE_POTION",
	name = "potion of lesser mana",
	color = colors.LIGHT_BLUE, image="object/potion-5x0.png",
	level_range = {1, 20},
	rarity = 3,
	cost = 3,

	use_simple = { name="restore some mana", use = function(self, who)
		who:incMana(40 + who:getMag())
		game.logSeen(who, "%s quaffs a %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end}
}

newEntity{ base = "BASE_POTION",
	name = "potion of mana",
	color = colors.LIGHT_BLUE, image="object/potion-5x0.png",
	level_range = {15, 35},
	rarity = 4,
	cost = 5,

	use_simple = { name="restore a good part of your mana", use = function(self, who)
		who:incMana(140 + who:getMag())
		game.logSeen(who, "%s quaffs a %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end}
}

newEntity{ base = "BASE_POTION",
	name = "potion of greater mana",
	color = colors.LIGHT_BLUE, image="object/potion-5x0.png",
	level_range = {30, 50},
	rarity = 5,
	cost = 7,

	use_simple = { name="restore a lot of mana", use = function(self, who)
		who:incMana(240 + who:getMag())
		game.logSeen(who, "%s quaffs a %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end}
}

newEntity{ base = "BASE_POTION",
	name = "potion of full mana", image="object/potion-5x0.png",
	color = colors.LIGHT_BLUE,
	level_range = {45, 50},
	rarity = 14,
	cost = 50,

	use_simple = { name="fully restore mana", use = function(self, who)
		who:incMana(1000000)
		game.logSeen(who, "%s quaffs a %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end}
}

-------------------------------------------------------
-- Curing
-------------------------------------------------------
newEntity{ base = "BASE_POTION",
	name = "potion of cure poison",
	color = colors.LIGHT_GREEN,
	level_range = {1, 50},
	rarity = 7,
	cost = 3,

	use_simple = { name="cures poison", use = function(self, who)
		if who:hasEffect(who.EFF_POISONED) then
			who:removeEffect(who.EFF_POISONED)
			game.logSeen(who, "%s cure %s from poisoning!", self:getName():capitalize(), who.name)
			return "destroy", true
		end
		return "destroy", false
	end}
}

-------------------------------------------------------
-- Misc
-------------------------------------------------------
newEntity{ base = "BASE_POTION",
	name = "potion of slime mold juice",
	color = colors.GREEN, image="object/potion-2x0.png",
	level_range = {1, 2},
	rarity = 4,
	cost = 0.01,

	use_simple = { name="quaff", use = function(self, who)
		game.logSeen(who, "%s quaffs the slime juice. Yuck.", who.name:capitalize())
		-- 1% chance of gaining slime mold powers
		if rng.percent(1) then
			who:learnTalentType("gift/slime", false)
			game.logSeen(who, "%s is transformed by the slime mold juice.", who.name:capitalize())
			game.logPlayer(who, "#00FF00#You gain an affinity for the molds. You can now learn new slime talents (press G).")
		end
		return "destroy", true
	end}
}

newEntity{ base = "BASE_POTION",
	name = "potion of speed",
	color = colors.LIGHT_BLUE,
	level_range = {15, 40},
	rarity = 10,
	cost = 1.5,

	use_simple = { name="increase your speed for a while", use = function(self, who)
		who:setEffect(who.EFF_SPEED, 5 + who:getMag(10), {power=1})
		return "destroy", true
	end}
}


newEntity{ base = "BASE_POTION",
	name = "potion of invisibility",
	color = colors.YELLOW,
	level_range = {15, 40},
	rarity = 10,
	cost = 1.5,

	use_simple = { name="become invisible for a while", use = function(self, who)
		who:setEffect(who.EFF_INVISIBILITY, 5 + who:getMag(10), {power=10 + who:getMag(5)})
		return "destroy", true
	end}
}

newEntity{ base = "BASE_POTION",
	name = "potion of see invisible",
	color = colors.YELLOW,
	level_range = {5, 30},
	rarity = 6,
	cost = 0.5,

	use_simple = { name="sense invisible for a while", use = function(self, who)
		who:setEffect(who.EFF_SEE_INVISIBLE, 25 + who:getMag(50), {power=10 + who:getMag(5)})
		return "destroy", true
	end}
}
