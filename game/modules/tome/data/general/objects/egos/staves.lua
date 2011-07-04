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
	name = " of power", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(30, 3),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "shimmering ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 8,
	wielder = {
		max_mana = resolvers.mbonus_material(70, 40),
	},
}


newEntity{
	power_source = {arcane=true},
	name = " of might", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 8,
	wielder = {
		combat_spellcrit = resolvers.mbonus_material(15, 4),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of wizardry", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 45,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(30, 3),
		max_mana = resolvers.mbonus_material(100, 10),
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(5, 1), [Stats.STAT_WIL] = resolvers.mbonus_material(5, 1) },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "magma ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.FIRE] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "temporal ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.TEMPORAL] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "icy ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.COLD] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "acidic ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.ACID] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "crackling ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.LIGHTNING] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {nature=true},
	name = "naturalist ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.NATURE] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "blighted ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.BLIGHT] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {nature=true},
	name = "sunbathed ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.LIGHT] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {nature=true},
	name = "shadow ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.DARKNESS] = resolvers.mbonus_material(25, 8), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of divination", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		talents_types_mastery = {
			["spell/divination"] = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return 0, v end),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of conveyance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		talents_types_mastery = {
			["spell/conveyance"] = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return 0, v end),
		},
	},
	max_power = 120, power_regen = 1,
	use_power = { name = "teleport you anywhere on the level, randomly", power = 60, use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 200)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return true, nil, true
	end}
}

newEntity{
	power_source = {nature=true},
	name = " of illumination", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		lite = 1,
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_ILLUMINATE, level = 2, power = 80 },
}

newEntity{
	power_source = {arcane=true},
	name = " of blasting", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 45,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(12, 3),
		combat_spellcrit = resolvers.mbonus_material(4, 2),
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(15, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(15, 5),
		},
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_BLASTWAVE, level = 2, power = 80 },
}


newEntity{
	power_source = {arcane=true},
	name = " of warding", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 45,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(12, 3),
		stun_immune = resolvers.mbonus_material(3, 3, function(e, v) v=v/10 return 0, v end),
		combat_def = resolvers.mbonus_material(16, 4),
		resists={
			[DamageType.ARCANE] = resolvers.mbonus_material(5, 5),
		},
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_DISPLACEMENT_SHIELD, level = 4, power = 80 },
}

newEntity{
	power_source = {arcane=true},
	name = " of channeling", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 45,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(12, 3),
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_METAFLOW, level = 3, power = 80 },
}

newEntity{
	power_source = {nature=true},
	name = "lifebinding ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 35,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(7, 3),
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(4, 3),
			},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "infernal ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 35,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(7, 3),
		see_invisible = resolvers.mbonus_material(15, 5),
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(20, 5),
			[DamageType.BLIGHT] = resolvers.mbonus_material(20, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "chronomancer's ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 35,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(7, 3),
		movement_speed = 0.1,
		inc_damage = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(20, 5),
		},
	},

}

newEntity{
	power_source = {nature=true},
	name = "abyssal ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 80,
	wielder = {
		blind_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, -v end),
		confusion_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, -v end),
		resource_leech_chance = resolvers.mbonus_material(10, 5),
		resource_leech_value = resolvers.mbonus_material(1, 1),
		inc_damage = {
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		resists_pen = { 
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
	},	
}

newEntity{
	power_source = {arcane=true},
	name = "magelord's ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 60,
	wielder = {
		max_mana = resolvers.mbonus_material(100, 20),
		combat_spellpower = resolvers.mbonus_material(20, 5),
	},	
}

newEntity{
	power_source = {arcane=true},
	name = "polar ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(12, 3),
		inc_damage = {
			[DamageType.COLD] = resolvers.mbonus_material(15, 5),
		},
		on_melee_hit = {
			[DamageType.ICE] = resolvers.mbonus_material(10, 5),
		},
	},	
}

newEntity{
	power_source = {arcane=true},
	name = "ethereal ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 10,
	cost = 20,
	wielder = {
		inc_damage = {
			[DamageType.ARCANE] = resolvers.mbonus_material(10, 5),
		},
		mana_regen = resolvers.mbonus_material(50, 10, function(e, v) v=v/100 return 0, v end),
		combat_spellpower = resolvers.mbonus_material(12, 3),
	},	
}

newEntity{
	power_source = {arcane=true},
	name = "bloodlich's ", prefix=true, instant_resolve=true,
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 90,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(9, 1),
		},
		inc_damage = {
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
	},	
}

newEntity{
	power_source = {arcane=true},
	name = " of conflagration", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		mana_regen = resolvers.mbonus_material(50, 10, function(e, v) v=v/100 return 0, -v end),
		combat_spellpower = resolvers.mbonus_material(12, 3),
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(20, 5),
		},
		resists_pen = { 
			[DamageType.FIRE] = resolvers.mbonus_material(20, 5),
		},
	},	
}

newEntity{
	power_source = {arcane=true},
	name = " of the stars", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_STARFALL, level = 2, power = 50 },
	wielder = {
		combat_spellpower = resolvers.mbonus_material(12, 3),
		inc_damage = {
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
	},	
}

newEntity{
	power_source = {nature=true},
	name = " of growth", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 40,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_STONE_VINES, level = 3, power = 80 },
	wielder = {
		max_life = resolvers.mbonus_material(70, 40),
		combat_spellpower = resolvers.mbonus_material(12, 3),
	},	
}

newEntity{
	power_source = {arcane=true},
	name = " of ruination", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_CORRUPTED_NEGATION, level = 4, power = 15 },
	wielder = {
		combat_spellpower = resolvers.mbonus_material(12, 3),
		inc_damage = {
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 5),
			[DamageType.POISON] = resolvers.mbonus_material(10, 5),
		},
	},	
}

newEntity{
	power_source = {arcane=true},
	name = " of lightning", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_CHAIN_LIGHTNING, level = 5, power = 60 },
	wielder = {
		combat_spellpower = resolvers.mbonus_material(12, 3),
		resists_pen = { 
			[DamageType.LIGHTNING] = resolvers.mbonus_material(25, 5),
		},
	},	
}
