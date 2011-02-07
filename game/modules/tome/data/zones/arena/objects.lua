-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
	is_magic_device = false,
	encumberance = 0,
}


-- Id stuff
newEntity{ define_as = "ORB_KNOWLEDGE",
	power_source = {unknown=true},
	unique = true, quest=true,
	type = "jewelry", subtype="orb",
	unided_name = "orb", no_unique_lore = true,
	name = "Orb of Knowledge", identified = true,
	display = "*", color=colors.VIOLET, image = "object/ruby.png",
	encumber = 1,
	desc = [[This orb was given to you by Elisa the halfling scryer, it will automatically identify normal and rare items for you and can be activated to identify all others.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "use the orb", power = 1,
		use = function(self, who)
			for inven_id, inven in pairs(who.inven) do
				for item, o in ipairs(inven) do
					if not o:isIdentified() then
						o:identify(true)
						game.logPlayer(who, "You have: %s", o:getName{do_colour=true})
					end
				end
			end
		end
	},

	carrier = {
		auto_id = 2,
	},
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
	greater_ego = true,
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
	greater_ego = true,
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
		return nil, true
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
	greater_ego = true,
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
	greater_ego = true,
	identified = true,
	cost = 0,
	material_level = 1,
	use_talent = { id = Talents.T_PIERCING_ARROW, level = 2, power = 10 },
	max_power = 10, power_regen = 1,
	combat = {
		range = 8,
		physspeed = 0.8,
	},
	basic_ammo = {
		dam = 20,
		apr = 5,
		physcrit = 1,
		dammod = {dex=0.7, str=0.5},
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
	greater_ego = true,
	identified = true,
	cost = 0,
	material_level = 1,
	use_talent = { id = Talents.T_FLARE, level = 3, power = 25 },
	max_power = 25, power_regen = 1,
	combat = {
		range = 8,
		physspeed = 0.8,
	},
	basic_ammo = {
		dam = 20,
		apr = 1,
		physcrit = 4,
		dammod = {dex=0.7, cun=0.5},
	},
}
