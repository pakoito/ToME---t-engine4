-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

load("/data/general/objects/objects.lua")
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_LORE",
	define_as = "ARENA_SCORING",
	name = "Arena for dummies", lore="arena-scoring",
	desc = [[A note explaining the arena's scoring rules. Someone must have dropped it.]],
	rarity = false,
	encumberance = 0,
}

newEntity{ define_as = "ARENA_BOOTS_DISE", name = "a pair of leather boots of disengagement",
	slot = "FEET",
	type = "armor", subtype="feet",
	power_source = {technique=true},
	add_name = " (#ARMOR#)#CHARGES#",
	display = "]", color=colors.UMBER, image = resolvers.image_material("boots", "leather"),
	encumber = 2,
	desc = [[A pair of boots made of leather. They seem to be of exceptional quality.]],
	suffix=true, instant_resolve=true,
	egoed = true,
	greater_ego = 1,
	identified = true,
	rarity = false,
	cost = 0,
	material_level = 1,
	wielder = {
		combat_armor = 2,
		fatigue = 1,
	},
	max_power = 12, power_regen = 1,
	use_talent = { id = Talents.T_DISENGAGE, level = 2, power = 12 },
}

newEntity{ define_as = "ARENA_BOOTS_PHAS", name = "a pair of leather boots of phasing",
	slot = "FEET",
	type = "armor", subtype="feet",
	power_source = {arcane=true},
	add_name = " (#ARMOR#)#CHARGES#",
	display = "]", color=colors.UMBER, image = resolvers.image_material("boots", "leather"),
	encumber = 2,
	desc = [[A pair of boots made of leather. They seem to be of exceptional quality.]],
	suffix=true, instant_resolve=true,
	egoed = true,
	greater_ego = 1,
	identified = true,
	cost = 0,
	rarity = false,
	material_level = 1,
	wielder = {
		combat_armor = 2,
		fatigue = 1,
	},
	max_power = 25, power_regen = 1,
	use_power = { name = "blink to a nearby random location", power = 15, use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 10 + who:getMag(5))
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game:playSoundNear(who, "talents/teleport")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end}
}

newEntity{ define_as = "ARENA_BOOTS_RUSH", name = "a pair of leather boots of rushing",
	slot = "FEET",
	type = "armor", subtype="feet",
	power_source = {technique=true},
	add_name = " (#ARMOR#)#CHARGES#",
	display = "]", color=colors.UMBER, image = resolvers.image_material("boots", "leather"),
	encumber = 2,
	desc = [[A pair of boots made of leather. They seem to be of exceptional quality.]],
	suffix=true, instant_resolve=true,
	egoed = true,
	rarity = false,
	greater_ego = 1,
	identified = true,
	cost = 0,
	material_level = 1,
	wielder = {
		combat_armor = 2,
		fatigue = 1,
	},
	max_power = 32, power_regen = 1,
	use_talent = { id = Talents.T_RUSH, level = 2, power = 32 },
}

newEntity{ define_as = "ARENA_BOW", name = "elm longbow of piercing arrows",
	base = "BASE_LONGBOW",
	level_range = {1, 10},
	power_source = {technique=true},
	require = { stat = { dex=11 }, },
	rarity = 30,
	add_name = " #CHARGES#",
	egoed = true,
	greater_ego = 1,
	identified = true,
	cost = 0,
	material_level = 1,
	use_talent = { id = Talents.T_PIERCING_ARROW, level = 2, power = 10 },
	max_power = 10, power_regen = 1,
	combat = {
		range = 8,
		physspeed = 0.8,
	},
}

newEntity{ define_as = "ARENA_SLING", name = "rough leather sling of flare",
	base = "BASE_SLING",
	level_range = {1, 10},
	power_source = {technique=true},
	require = { stat = { dex=11 }, },
	add_name = " #CHARGES#",
	rarity = 30,
	egoed = true,
	greater_ego = 1,
	identified = true,
	cost = 0,
	material_level = 1,
	use_talent = { id = Talents.T_FLARE, level = 3, power = 25 },
	max_power = 25, power_regen = 1,
	combat = {
		range = 8,
		physspeed = 0.8,
	},
}
