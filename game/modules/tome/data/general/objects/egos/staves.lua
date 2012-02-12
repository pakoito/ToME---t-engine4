-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

--load("/data/general/objects/egos/charged-attack.lua")
--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	power_source = {arcane=true},
	name = " of warding", suffix=true, instant_resolve=true,
	keywords = {warding=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 20,
	wielder = {
		learn_talent = {
			[Talents.T_WARD] = resolvers.mbonus_material("learn_talent"),
		},
		wards = {},
	},
	combat = {of_warding = true},
	resolvers.genericlast(function(e)
		for d, v in pairs(e.wielder.inc_damage) do
			e.wielder.wards[d] = 2
		end
	end),
}

newEntity{
	power_source = {technique=true},
	name = " of savagery", suffix=true, instant_resolve=true,
	keywords = {savagery=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		learn_talent = {
			[Talents.T_SAVAGERY] = resolvers.mbonus_material("learn_talent_5"),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of draining", suffix=true, instant_resolve=true,
	keywords = {draining=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		learn_talent = {
			[Talents.T_SOUL_DRAIN] = resolvers.mbonus_material("learn_talent_5"),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of retribution", suffix=true, instant_resolve=true,
	keywords = {retribution=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 20,
	wielder = {
		learn_talent = {
			[Talents.T_ELEMENTAL_RETRIBUTION] = resolvers.mbonus_material("learn_talent_5"),
		},
		elemental_retribution = {},
	},
	combat = {of_retribution = true},
	resolvers.genericlast(function(e)
		for d, v in pairs(e.wielder.inc_damage) do
			e.wielder.elemental_retribution[d] = 1
		end
	end),
}

newEntity{
	power_source = {arcane=true},
	name = " of breaching", suffix=true, instant_resolve=true,
	keywords = {breaching=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		resists_pen = {},
	},
	combat = {of_breaching = true},
	resolvers.genericlast(function(e)
		for d, v in pairs(e.wielder.inc_damage) do
			e.wielder.resists_pen[d] = v/2
		end
	end),
}

newEntity{
	power_source = {arcane=true},
	name = "potent ", prefix=true, instant_resolve=true,
	keywords = {potent=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat = {
		dam = resolvers.mbonus_material("dam"),
	},
	resolvers.genericlast(function(e)
		e.wielder.inc_damage[e.combat.damtype] = e.combat.dam
		if e.combat.of_breaching then
			for d, v in pairs(e.wielder.inc_damage) do
				e.wielder.resists_pen[d] = math.ceil(e.combat.dam/2)
			end
		end
	end),
}

newEntity{
	power_source = {technique=true},
	name = "cruel ", prefix=true, instant_resolve=true,
	keywords = {cruel=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat = {
		critical_power = resolvers.mbonus_material("critical_power"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "tuned ", prefix=true, instant_resolve=true,
	keywords = {tuned=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat = {
		max_acc = resolvers.mbonus_material("max_acc"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "evoker's ", prefix=true, instant_resolve=true,
	keywords = {evoker=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 25,
	combat = {
		dam = resolvers.mbonus_material("dam"),
		critical_power = resolvers.mbonus_material("critical_power"),
	},
	resolvers.genericlast(function(e)
		e.wielder.inc_damage[e.combat.damtype] = e.combat.dam
		if e.combat.of_breaching then
			for d, v in pairs(e.wielder.inc_damage) do
				e.wielder.resists_pen[d] = math.ceil(e.combat.dam/2)
			end
		end
	end),
}

newEntity{
	power_source = {arcane=true},
	name = "ritualist's ", prefix=true, instant_resolve=true,
	keywords = {ritualist=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 25,
	combat = {
		dam = resolvers.mbonus_material("dam"),
		max_acc = resolvers.mbonus_material("max_acc"),
	},
	resolvers.genericlast(function(e)
		e.wielder.inc_damage[e.combat.damtype] = e.combat.dam
		if e.combat.of_breaching then
			for d, v in pairs(e.wielder.inc_damage) do
				e.wielder.resists_pen[d] = math.ceil(e.combat.dam/2)
			end
		end
	end),
}

newEntity{
	power_source = {technique=true},
	name = "sadist's ", prefix=true, instant_resolve=true,
	keywords = {sadist=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 25,
	combat = {
		max_acc = resolvers.mbonus_material("max_acc"),
		critical_power = resolvers.mbonus_material("critical_power"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "greater ", prefix=true, instant_resolve=true,
	keywords = {greater=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 25,
	combat = {is_greater = true,},
	resolvers.generic(function(e)
		local dam_tables = {
			magestaff = {engine.DamageType.FIRE, engine.DamageType.COLD, engine.DamageType.LIGHTNING, engine.DamageType.ARCANE},
			starstaff = {engine.DamageType.LIGHT, engine.DamageType.DARKNESS, engine.DamageType.TEMPORAL},
			earthstaff = {engine.DamageType.NATURE, engine.DamageType.BLIGHT, engine.DamageType.ACID},
		}
		local d_table = dam_tables[e.flavor_name]
		for i = 1, #d_table do
			e.wielder.inc_damage[d_table[i]] = e.combat.dam
		end
	end),
}

newEntity{
	power_source = {nature=true},
	name = " of blood", suffix=true, instant_resolve=true,
	keywords = {blood=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		learn_talent = {
			[Talents.T_BLOODFLOW] = resolvers.mbonus_material("learn_talent_5"),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "parasitic ", prefix=true, instant_resolve=true,
	keywords = {parasitic=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 60,
	cost = 40,
	wielder = {
		resource_leech_chance = resolvers.mbonus_material("resource_leech_chance"),
		resource_leech_value = resolvers.mbonus_material("resource_leech_value"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of channeling", suffix=true, instant_resolve=true,
	keywords = {channeling=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 20,
	wielder = {
		learn_talent = {
			[Talents.T_CHANNEL_STAFF] = resolvers.mbonus_material("learn_talent"),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "sentient ", prefix=true, instant_resolve=true,
	keywords = {sentient=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 60,
	cost = 200,
	combat = {
		sentient = resolvers.rngtable{"default", "aggressive", "fawning"},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of wizardry", suffix=true, instant_resolve=true,
	keywords = {wizardry=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 45,
	wielder = {
		learn_talent = {
			[Talents.T_ELEMENTAL_RETRIBUTION] = resolvers.mbonus_material("learn_talent_5"),
			[Talents.T_METAFLOW] = resolvers.mbonus_material("learn_talent"),
			[Talents.T_COMMAND_STAFF] = resolvers.mbonus_material("learn_talent"),
		},
		elemental_retribution = {},
	},
	combat = {
		of_retribution = true,
		max_acc = resolvers.mbonus_material("max_acc"),
	},
	resolvers.genericlast(function(e)
		for d, v in pairs(e.wielder.inc_damage) do
			e.wielder.elemental_retribution[d] = 1
		end
	end),
}

newEntity{
	power_source = {arcane=true},
	name = "shadowy ", prefix=true, instant_resolve=true,
	keywords = {shadowy=true},
	level_range = {1, 50},
	rarity = 20,
	cost = 20,
	wielder = {
		learn_talent = {
			[Talents.T_FEARSCAPE_FOG] = resolvers.mbonus_material("learn_talent"),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of perception", suffix=true, instant_resolve=true,
	keywords = {perception=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	wielder = {
		learn_talent = {
			[Talents.T_PERCEPTION] = resolvers.mbonus_material("learn_talent_5"),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of conveyance", suffix=true, instant_resolve=true,
	keywords = {conveyance=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		talents_types_mastery = {
			["spell/conveyance"] = resolvers.mbonus_material("talents_types_mastery"),
		},
	},
	max_power = 120, power_regen = 1,
	use_power = { name = "teleport you anywhere on the level, randomly", power = 70, use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 200)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end}
}

newEntity{
	power_source = {nature=true},
	name = " of illumination", suffix=true, instant_resolve=true,
	keywords = {illumination=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	wielder = {
		lite = resolvers.mbonus_material("lite"),
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_ILLUMINATE, level = resolvers.mbonus_material("learn_talent_5"), power = 10 },
}

newEntity{
	power_source = {arcane=true},
	name = " of blasting", suffix=true, instant_resolve=true,
	keywords = {blasting=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 45,
	combat = {
		critical_power = resolvers.mbonus_material("critical_power"),
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_BLASTWAVE, level = resolvers.mbonus_material("learn_talent_5"), power = 50 },
}


newEntity{
	power_source = {arcane=true},
	name = " of displacement", suffix=true, instant_resolve=true,
	keywords = {displacement=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 20,
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_DISPLACEMENT_SHIELD, level = resolvers.mbonus_material("learn_talent_5"), power = 20 },
}

newEntity{
	power_source = {arcane=true},
	name = " of renewal", suffix=true, instant_resolve=true,
	keywords = {renewal=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 45,
	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_METAFLOW, level = resolvers.mbonus_material("learn_talent_5"), power = 50 },
}

newEntity{
	power_source = {nature=true},
	name = "lifebinding ", prefix=true, instant_resolve=true,
	keywords = {lifebinding=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 80,
	wielder = {
		learn_talent = {
			[Talents.T_LIFEBIND] = resolvers.mbonus_material("learn_talent_5"),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "ghostly ", prefix=true, instant_resolve=true,
	keywords = {ghostly=true},
	level_range = {1, 50},
	rarity = 15,
	cost = 15,
	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_WRAITHFORM, level = resolvers.mbonus_material("learn_talent_5"), power = 50 },
}

newEntity{
	power_source = {arcane=true},
	name = " of negation", suffix=true, instant_resolve=true,
	keywords = {negation=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 20,
	max_power = 40, power_regen = 1,
	use_talent = { id = Talents.T_CORRUPTED_NEGATION, level = resolvers.mbonus_material("learn_talent_5"), power = 40 },
}
