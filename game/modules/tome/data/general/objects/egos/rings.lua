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
local DamageType = require "engine.DamageType"

--load("/data/general/objects/egos/charged-attack.lua")
--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	power_source = {arcane=true},
	name = " of see invisible", suffix=true, instant_resolve=true,
	keywords = {seeInvis=true},
	level_range = {1, 20},
	rarity = 4,
	cost = 2,
	wielder = {
		see_invisible = resolvers.mbonus_material("see_invisible"),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of regeneration (#REGEN#)", suffix=true,
	keywords = {regen=true},
	level_range = {10, 20},
	rarity = 10,
	cost = 8,
	wielder = {
		life_regen = resolvers.mbonus_material("life_regen"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of mana (#REGEN#)", suffix=true, instant_resolve=true,
	keywords = {mana=true},
	level_range = {10, 20},
	rarity = 8,
	cost = 3,
	wielder = {
		mana_regen = resolvers.mbonus_material("mana_regen"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of fire (#DAMBONUS#)", suffix=true, instant_resolve=true,
	keywords = {fire=true},
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.FIRE] = resolvers.mbonus_material("inc_damage") },
		wards = {[DamageType.FIRE] = resolvers.mbonus_material("wards")},
		learn_talent = {[Talents.T_WARD] = resolvers.mbonus_material("learn_talent")},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of time (#DAMBONUS#)", suffix=true, instant_resolve=true,
	keywords = {time=true},
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.TEMPORAL] = resolvers.mbonus_material("inc_damage") },
		wards = {[DamageType.TEMPORAL] = resolvers.mbonus_material("wards")},
		learn_talent = {[Talents.T_WARD] = resolvers.mbonus_material("learn_talent")},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of frost (#DAMBONUS#)", suffix=true, instant_resolve=true,
	keywords = {frost=true},
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.COLD] = resolvers.mbonus_material("inc_damage") },
		wards = {[DamageType.COLD] = resolvers.mbonus_material("wards")},
		learn_talent = {[Talents.T_WARD] = resolvers.mbonus_material("learn_talent")},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of nature (#DAMBONUS#)", suffix=true, instant_resolve=true,
	keywords = {nature=true},
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.NATURE] = resolvers.mbonus_material("inc_damage") },
		wards = {[DamageType.NATURE] = resolvers.mbonus_material("wards")},
		learn_talent = {[Talents.T_WARD] = resolvers.mbonus_material("learn_talent")},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of lightning (#DAMBONUS#)", suffix=true, instant_resolve=true,
	keywords = {lightning=true},
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.LIGHTNING] = resolvers.mbonus_material("inc_damage") },
		wards = {[DamageType.LIGHTNING] = resolvers.mbonus_material("wards")},
		learn_talent = {[Talents.T_WARD] = resolvers.mbonus_material("learn_talent")},
	},

}

newEntity{
	power_source = {nature=true},
	name = " of corrosion (#DAMBONUS#)", suffix=true, instant_resolve=true,
	keywords = {corrosion=true},
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.ACID] = resolvers.mbonus_material("inc_damage") },
		wards = {[DamageType.ACID] = resolvers.mbonus_material("wards")},
		learn_talent = {[Talents.T_WARD] = resolvers.mbonus_material("learn_talent")},
	},

}

newEntity{
	power_source = {arcane=true},
	name = " of blight (#DAMBONUS#)", suffix=true, instant_resolve=true,
	keywords = {blight=true},
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.BLIGHT] = resolvers.mbonus_material("inc_damage") },
		wards = {[DamageType.BLIGHT] = resolvers.mbonus_material("wards")},
		learn_talent = {[Talents.T_WARD] = resolvers.mbonus_material("learn_talent")},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of massacre", suffix=true, instant_resolve=true,
	keywords = {massacre=true},
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		combat_dam = resolvers.mbonus_material("combat_dam", 2),
		--inc_damage = { [DamageType.PHYSICAL] = resolvers.mbonus_material("inc_damage") },
	},
}

newEntity{ define_as = "RING_ARCANE_POWER",
	power_source = {arcane=true},
	name = " of arcane power (#DAMBONUS#)", suffix=true, instant_resolve=true,
	keywords = {arcane=true},
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.ARCANE] = resolvers.mbonus_material("inc_damage") },
		wards = {[DamageType.ARCANE] = resolvers.mbonus_material("wards")},
		learn_talent = {[Talents.T_WARD] = resolvers.mbonus_material("learn_talent")},
	},
}

newEntity{
	power_source = {technique=true},
	name = "savior's ", prefix=true, instant_resolve=true,
	keywords = {savior=true},
	greater_ego = 1,
	level_range = {1, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material("save"),
		combat_physresist = resolvers.mbonus_material("save"),
		combat_spellresist = resolvers.mbonus_material("save"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "brawler's ", prefix=true, instant_resolve=true,
	keywords = {brawler=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material("inc_stats") },
	},
	resolvers.genericlast(function(e) e.wielder.combat_def = (e.wielder.combat_def or 0) + e.wielder.inc_stats[engine.interface.ActorStats.STAT_STR] end),
}

newEntity{
	power_source = {technique=true},
	name = "titan's ", prefix=true, instant_resolve=true,
	keywords = {titan=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = resolvers.mbonus_material("inc_stats") },
	},
	resolvers.genericlast(function(e) e.wielder.combat_physresist = (e.wielder.combat_physresist or 0) + e.wielder.inc_stats[engine.interface.ActorStats.STAT_CON] end),
}

newEntity{
	power_source = {technique=true},
	name = "duelist's ", prefix=true, instant_resolve=true,
	keywords = {duelist=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats") },
	},
	resolvers.genericlast(function(e) e.wielder.combat_atk = (e.wielder.combat_atk or 0) + e.wielder.inc_stats[engine.interface.ActorStats.STAT_DEX] end),
}

newEntity{ define_as = "RING_MAGIC",
	power_source = {arcane=true},
	name = "wizard's ", prefix=true, instant_resolve=true,
	keywords = {wizard=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats") },
	},
	resolvers.genericlast(function(e) e.wielder.combat_spellresist = (e.wielder.combat_spellresist or 0) + e.wielder.inc_stats[engine.interface.ActorStats.STAT_MAG] end),
}

newEntity{
	power_source = {arcane=true},
	name = "mule's ", prefix=true, instant_resolve=true,
	keywords = {mule=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		max_encumber = resolvers.mbonus_material("max_encumber"),
		fatigue = resolvers.mbonus_material("fatigue"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "sneakthief's ", prefix=true, instant_resolve=true,
	keywords = {sneakthief=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 12,
	cost = 20,
	wielder = {
		lite = resolvers.mbonus_material("lite", -1),
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
	},
	},
}

newEntity{
	power_source = {technique=true},
	name = "gladiator's ", prefix=true, instant_resolve=true,
	keywords = {gladiator=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 12,
	cost = 20,
	wielder = {
		combat_dam = resolvers.mbonus_material("combat_dam"),
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
	},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "conjurer's ", prefix=true, instant_resolve=true,
	keywords = {conjurer=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 12,
	cost = 20,
	wielder = {
		mana_regen = resolvers.mbonus_material("mana_regen"),
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats"),
			},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of tenacity", suffix=true, instant_resolve=true,
	keywords = {tenacity=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 12,
	cost = 50,
	wielder = {
		pin_immune = resolvers.mbonus_material("immunity"),
		knockback_immune = resolvers.mbonus_material("immunity"),
		disarm_immune = resolvers.mbonus_material("immunity"),
	},
}


newEntity{
	power_source = {arcane=true},
	name = " of evocation", suffix=true, instant_resolve=true,
	keywords = {evocation=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 12,
	cost = 50,
	wielder = {
		combat_spellpower = resolvers.mbonus_material("combat_spellpower"),
		combat_spellcrit = resolvers.mbonus_material("combat_spellcrit"),
		inc_damage = { [DamageType.ARCANE] = resolvers.mbonus_material("inc_damage") },
	},
}

newEntity{
	power_source = {nature=true},
	name = " of life", suffix=true, instant_resolve=true,
	keywords = {life=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 12,
	cost = 50,
	wielder = {
		max_life=resolvers.mbonus_material("max_life"),
		life_regen = resolvers.mbonus_material("life_regen"),
		healing_factor = resolvers.mbonus_material("healing_factor"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "painweaver's ", prefix=true, instant_resolve=true,
	keywords = {painweaver=true},
	level_range = {5, 35},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		healing_factor = resolvers.mbonus_material("healing_factor", -1),
		combat_spellpower = resolvers.mbonus_material("combat_spellpower", 2),
		combat_dam = resolvers.mbonus_material("combat_dam", 2),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "firelord's ", prefix=true, instant_resolve=true,
	keywords = {firelord=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material("inc_damage"),
		},
		resists_pen = {
			[DamageType.FIRE] = resolvers.mbonus_material("resists_pen"),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "otherworldly ", prefix=true, instant_resolve=true,
	keywords = {otherworldly=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		resists={
			[DamageType.ARCANE] = resolvers.mbonus_material("rare_resists"),
		},
		inc_damage = {
			[DamageType.ARCANE] = resolvers.mbonus_material("inc_damage"),
		},
		lite = resolvers.mbonus_material("lite"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "savage's ", prefix=true, instant_resolve=true,
	keywords = {savage=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
		},
		combat_spellresist = resolvers.mbonus_material("combat_spellresist"),
		max_stamina = resolvers.mbonus_material("max_stamina"),
	},
}

newEntity{
	power_source = {nature=true},
	name = "treant's ", prefix=true, instant_resolve=true,
	keywords = {treant=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 40,
	wielder = {
		resists={
			[DamageType.NATURE] = resolvers.mbonus_material("resists"),
		},
		poison_immune = resolvers.mbonus_material("immunity"),
		disease_immune = resolvers.mbonus_material("immunity"),
		combat_physresist = resolvers.mbonus_material("save"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "shivering ", prefix=true, instant_resolve=true,
	keywords = {shivering=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		inc_damage = {
			[DamageType.COLD] = resolvers.mbonus_material("inc_damage"),
		},
		resists_pen = {
			[DamageType.COLD] = resolvers.mbonus_material("resists_pen"),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of misery", suffix=true, instant_resolve=true,
	keywords = {misery=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_BLEEDING_EDGE, level = 4, power = 80 },
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats", 2),
		},
		combat_mentalresist = resolvers.mbonus_material("save", -1),
		combat_physresist = resolvers.mbonus_material("save", -1),
		combat_spellresist = resolvers.mbonus_material("save", -1),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of warding", suffix=true, instant_resolve=true,
	keywords = {warding=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material("resists"),
			[DamageType.LIGHTNING] = resolvers.mbonus_material("resists"),
			[DamageType.FIRE] = resolvers.mbonus_material("resists"),
			[DamageType.COLD] = resolvers.mbonus_material("resists"),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of focus", suffix=true, instant_resolve=true,
	keywords = {focus=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 100,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_GREATER_WEAPON_FOCUS, level = 4, power = 80 },
	wielder = {
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material("resists_pen"),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of pilfering", suffix=true, instant_resolve=true,
	keywords = {pilfering=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_DISENGAGE, level = 2, power = 40 },
	wielder = {
		combat_apr = resolvers.mbonus_material("combat_apr"),
		combat_def = resolvers.mbonus_material("combat_def"),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of speed", suffix=true, instant_resolve=true,
	keywords = {speed=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 140,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_BLINDING_SPEED, level = 4, power = 80 },
	wielder = {
		movement_speed = resolvers.mbonus_material("movement_speed"),
	},
}
--[=[
newEntity{
	power_source = {arcane=true},
	name = " of blasting", suffix=true, instant_resolve=true,
	keywords = {blasting=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		melee_project = {
			[DamageType.LIGHTNING] = resolvers.mbonus_material("melee_project"),
			[DamageType.PHYSICAL] = resolvers.mbonus_material("melee_project"),
		},
	},
}
]=]
