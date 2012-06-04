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
		see_invisible = resolvers.mbonus_material(20, 5),
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
		life_regen = resolvers.mbonus_material(30, 5, function(e, v) v=v/10 return 0, v end),
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
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of fire (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {fire=true},
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.FIRE] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.FIRE] = (e.wielder.resists[engine.DamageType.FIRE] or 0) + e.wielder.inc_damage[engine.DamageType.FIRE] end),
}

newEntity{
	power_source = {arcane=true},
	name = " of time (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {time=true},
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.TEMPORAL] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.TEMPORAL] = (e.wielder.resists[engine.DamageType.TEMPORAL] or 0) + e.wielder.inc_damage[engine.DamageType.TEMPORAL] end),
}

newEntity{
	power_source = {arcane=true},
	name = " of frost (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {frost=true},
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.COLD] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.COLD] = (e.wielder.resists[engine.DamageType.COLD] or 0) + e.wielder.inc_damage[engine.DamageType.COLD] end),
}

newEntity{
	power_source = {nature=true},
	name = " of nature (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {nature=true},
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.NATURE] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.NATURE] = (e.wielder.resists[engine.DamageType.NATURE] or 0) + e.wielder.inc_damage[engine.DamageType.NATURE] end),
}

newEntity{
	power_source = {arcane=true},
	name = " of lightning (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {lightning=true},
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.LIGHTNING] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.LIGHTNING] = (e.wielder.resists[engine.DamageType.LIGHTNING] or 0) + e.wielder.inc_damage[engine.DamageType.LIGHTNING] end),
}

newEntity{
	power_source = {nature=true},
	name = " of corrosion (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {corrosion=true},
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.ACID] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.ACID] = (e.wielder.resists[engine.DamageType.ACID] or 0) + e.wielder.inc_damage[engine.DamageType.ACID] end),
}

newEntity{
	power_source = {arcane=true},
	name = " of blight (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {blight=true},
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.BLIGHT] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.BLIGHT] = (e.wielder.resists[engine.DamageType.BLIGHT] or 0) + e.wielder.inc_damage[engine.DamageType.BLIGHT] end),
}

newEntity{
	power_source = {nature=true},
	name = " of massacre (#DAMBONUS#)", suffix=true, instant_resolve=true,
	keywords = {massacre=true},
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5) },
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
		inc_damage = { [DamageType.ARCANE] = resolvers.mbonus_material(15, 5) },
	},
}

newEntity{
	power_source = {technique=true},
	name = "savior's ", prefix=true, instant_resolve=true,
	keywords = {savior=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		combat_physresist = resolvers.mbonus_material(10, 5),
		combat_spellresist = resolvers.mbonus_material(10, 5),
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
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(8, 2) },
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
		inc_stats = { [Stats.STAT_CON] = resolvers.mbonus_material(8, 2) },
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
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material(8, 2) },
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
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(8, 2) },
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
		max_encumber = resolvers.mbonus_material(20, 20),
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return 0, -v end),
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
		lite = -2,
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(6, 4),
			[Stats.STAT_CUN] = resolvers.mbonus_material(6, 4),
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
		combat_dam = resolvers.mbonus_material(10, 5),
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(6, 4),
			[Stats.STAT_CON] = resolvers.mbonus_material(6, 4),
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
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(4, 4),
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 4),
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
		pin_immune = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return 0, v end),
		knockback_immune = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return 0, v end),
		disarm_immune = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return 0, v end),
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
		combat_spellpower = resolvers.mbonus_material(3, 3),
		combat_spellcrit = resolvers.mbonus_material(3, 3),
		inc_damage = { [DamageType.ARCANE] = resolvers.mbonus_material(15, 5) },
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
		max_life=resolvers.mbonus_material(60, 40),
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "painweaver's ", prefix=true, instant_resolve=true,
	keywords = {painweaver=true},
	level_range = {5, 35},
	rarity = 20,
	cost = 60,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(15, 5),
		combat_dam = resolvers.mbonus_material(15, 5),
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
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
		},
		melee_project = {
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
		},
		resists_pen = {
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
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
			[DamageType.ARCANE] = resolvers.mbonus_material(7, 3),
		},
		inc_damage = {
			[DamageType.ARCANE] = resolvers.mbonus_material(20, 5),
		},
		lite = resolvers.mbonus_material(1, 1),
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
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		combat_spellresist = resolvers.mbonus_material(7, 3),
		max_stamina = resolvers.mbonus_material(30, 10),
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
			[DamageType.NATURE] = resolvers.mbonus_material(10, 5),
		},
		poison_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		disease_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		combat_physresist = resolvers.mbonus_material(7, 3),
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
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
		melee_project = {
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
		resists_pen = {
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
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
	resolvers.charmt(Talents.T_BLEEDING_EDGE, {2,3,4}, 20),
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(9, 1),
		},
		combat_mentalresist = resolvers.mbonus_material(5, 5, function(e, v) return 0, -v end),
		combat_physresist = resolvers.mbonus_material(5, 5, function(e, v) return 0, -v end),
		combat_spellresist = resolvers.mbonus_material(5, 5, function(e, v) return 0, -v end),
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
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
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
	resolvers.charmt(Talents.T_GREATER_WEAPON_FOCUS, {2,3,4}, 20),
	wielder = {
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
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
	resolvers.charmt(Talents.T_DISENGAGE, 2, 30),
	wielder = {
		combat_apr = resolvers.mbonus_material(7, 3),
		combat_def = resolvers.mbonus_material(7, 3),
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
	resolvers.charmt(Talents.T_BLINDING_SPEED, {2,3,4}, 40),
	wielder = {
		movement_speed = resolvers.mbonus_material(12, 3, function(e, v) v=v/100 return 0, v end),
	},
}

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
			[DamageType.LIGHTNING] = resolvers.mbonus_material(12, 3),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(12, 3),
		},
	},
}

