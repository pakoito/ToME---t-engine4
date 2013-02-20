-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

-- Immunity/Resist rings
newEntity{
	power_source = {arcane=true},
	name = " of sensing", suffix=true, instant_resolve=true,
	keywords = {sensing=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 2,
	wielder = {
		see_invisible = resolvers.mbonus_material(20, 5),
		see_stealth = resolvers.mbonus_material(20, 5),
		blind_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of clarity", suffix=true, instant_resolve=true,
	keywords = {clarity=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 2,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		confusion_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of tenacity", suffix=true, instant_resolve=true,
	keywords = {tenacity=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 5,
	wielder = {
		pin_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
		knockback_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
		disarm_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of perseverance", suffix=true, instant_resolve=true,
	keywords = {perseverance =true},
	level_range = {1, 50},
	rarity = 4,
	cost = 5,
	wielder = {
		life_regen = resolvers.mbonus_material(30, 5, function(e, v) v=v/10 return 0, v end),
		stun_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of arcana(#REGEN#)", suffix=true, instant_resolve=true,
	keywords = {arcana=true},
	level_range = {1, 20},
	rarity = 6,
	cost = 3,
	wielder = {
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
		silence_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of fire (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {fire=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.FIRE] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.FIRE] = (e.wielder.resists[engine.DamageType.FIRE] or 0) + (e.wielder.inc_damage[engine.DamageType.FIRE]*2) end),
}

newEntity{
	power_source = {nature=true},
	name = " of frost (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {frost=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.COLD] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.COLD] = (e.wielder.resists[engine.DamageType.COLD] or 0) + (e.wielder.inc_damage[engine.DamageType.COLD]*2) end),
}

newEntity{
	power_source = {nature=true},
	name = " of nature (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {nature=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.NATURE] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.NATURE] = (e.wielder.resists[engine.DamageType.NATURE] or 0) + (e.wielder.inc_damage[engine.DamageType.NATURE]*2) end),
}

newEntity{
	power_source = {nature=true},
	name = " of lightning (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {lightning=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.LIGHTNING] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.LIGHTNING] = (e.wielder.resists[engine.DamageType.LIGHTNING] or 0) + (e.wielder.inc_damage[engine.DamageType.LIGHTNING]*2) end),
}

newEntity{
	power_source = {arcane=true},
	name = " of light (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {light=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.LIGHT] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.LIGHT] = (e.wielder.resists[engine.DamageType.LIGHT] or 0) + (e.wielder.inc_damage[engine.DamageType.LIGHT]*2) end),
}

newEntity{
	power_source = {arcane=true},
	name = " of darkness (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {darkness=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.DARKNESS] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.DARKNESS] = (e.wielder.resists[engine.DamageType.DARKNESS] or 0) + (e.wielder.inc_damage[engine.DamageType.DARKNESS]*2) end),
}

newEntity{
	power_source = {nature=true},
	name = " of corrosion (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {corrosion=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.ACID] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.ACID] = (e.wielder.resists[engine.DamageType.ACID] or 0) + (e.wielder.inc_damage[engine.DamageType.ACID]*2) end),
}

-- rare resists
newEntity{
	power_source = {arcane=true},
	name = " of aether (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {aether=true},
	level_range = {1, 50},
	rarity = 24,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.ARCANE] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.ARCANE] = (e.wielder.resists[engine.DamageType.ARCANE] or 0) + (e.wielder.inc_damage[engine.DamageType.ARCANE]) end),
}

newEntity{
	power_source = {arcane=true},
	name = " of blight (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {blight=true},
	level_range = {1, 50},
	rarity = 24,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.BLIGHT] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.BLIGHT] = (e.wielder.resists[engine.DamageType.BLIGHT] or 0) + (e.wielder.inc_damage[engine.DamageType.BLIGHT]) end),
}

newEntity{
	power_source = {nature=true},
	name = " of the mountain (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {mountain=true},
	level_range = {1, 50},
	rarity = 24,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.PHYSICAL] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.PHYSICAL] = (e.wielder.resists[engine.DamageType.PHYSICAL] or 0) + (e.wielder.inc_damage[engine.DamageType.PHYSICAL]) end),
}

newEntity{
	power_source = {psionic=true},
	name = " of the mind (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {mind=true},
	level_range = {1, 50},
	rarity = 24,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.MIND] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.MIND] = (e.wielder.resists[engine.DamageType.MIND] or 0) + (e.wielder.inc_damage[engine.DamageType.MIND]) end),
}

newEntity{
	power_source = {arcane=true},
	name = " of time (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {time=true},
	level_range = {1, 50},
	rarity = 24,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.TEMPORAL] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.TEMPORAL] = (e.wielder.resists[engine.DamageType.TEMPORAL] or 0) + (e.wielder.inc_damage[engine.DamageType.TEMPORAL]) end),
}

-- The rest
newEntity{ 
	power_source = {arcane=true},
	name = " of arcane power", suffix=true, instant_resolve=true,
	keywords = {arcane=true},
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(10, 5),
	},
}
newEntity{
	power_source = {technique=true},
	name = " of physical power ", suffix=true, instant_resolve=true,
	keywords = {physical=true},
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		combat_dam = resolvers.mbonus_material(10, 5),
	},
}
newEntity{ 
	power_source = {psionic=true},
	name = " of mental power", suffix=true, instant_resolve=true,
	keywords = {mental=true},
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(10, 5),
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
	name = "warrior's ", prefix=true, instant_resolve=true,
	keywords = {warrior=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(8, 2) },
	},
	resolvers.genericlast(function(e) e.wielder.combat_armor = (e.wielder.combat_armor or 0) + (e.wielder.inc_stats[engine.interface.ActorStats.STAT_STR]*2) end),
}
newEntity{
	power_source = {technique=true},
	name = "rogue's ", prefix=true, instant_resolve=true,
	keywords = {rogue=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = resolvers.mbonus_material(8, 2) },
	},
	resolvers.genericlast(function(e) e.wielder.combat_def = (e.wielder.combat_def or 0) + (e.wielder.inc_stats[engine.interface.ActorStats.STAT_CUN]*2) end),
}
newEntity{
	power_source = {technique=true},
	name = "marksman's ", prefix=true, instant_resolve=true,
	keywords = {marskman=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material(8, 2) },
	},
	resolvers.genericlast(function(e) e.wielder.combat_atk = (e.wielder.combat_atk or 0) + (e.wielder.inc_stats[engine.interface.ActorStats.STAT_DEX]*2) end),
}
newEntity{
	power_source = {nature=true},
	name = "titan's ", prefix=true, instant_resolve=true,
	keywords = {titan=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = resolvers.mbonus_material(8, 2) },
	},
	resolvers.genericlast(function(e) e.wielder.combat_physresist = (e.wielder.combat_physresist or 0) + (e.wielder.inc_stats[engine.interface.ActorStats.STAT_CON]*2) end),
}

newEntity{
	power_source = {arcane=true},
	name = "wizard's ", prefix=true, instant_resolve=true,
	keywords = {wizard=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(8, 2) },
	},
	resolvers.genericlast(function(e) e.wielder.combat_spellresist = (e.wielder.combat_spellresist or 0) + (e.wielder.inc_stats[engine.interface.ActorStats.STAT_MAG]*2) end),
}

newEntity{
	power_source = {psionic=true},
	name = "psionicist's ", prefix=true, instant_resolve=true,
	keywords = {psionic=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = resolvers.mbonus_material(8, 2) },
	},
	resolvers.genericlast(function(e) e.wielder.combat_mentalresist = (e.wielder.combat_mentalresist or 0) + (e.wielder.inc_stats[engine.interface.ActorStats.STAT_WIL]*2) end),
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
		combat_spellpower = resolvers.mbonus_material(10, 5),
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(4, 4),
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 4),
		},
	},
}
newEntity{
	power_source = {psionic=true},
	name = "solipsist's ", prefix=true, instant_resolve=true,
	keywords = {solipsist=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 12,
	cost = 20,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(10, 5),
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(4, 4),
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 4),
		},
	},
}

newEntity{
	power_source = {technique=true},
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
	power_source = {technique=true},
	name = "painweaver's ", prefix=true, instant_resolve=true,
	keywords = {painweaver=true},
	level_range = {30, 50},
	rarity = 20,
	cost = 60,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(15, 5),
		combat_dam = resolvers.mbonus_material(15, 5),
		combat_mindpower = resolvers.mbonus_material(15, 5),
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
		combat_spellresist = resolvers.mbonus_material(10, 5),
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
		combat_physresist = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {psionic=true},
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
		hate_on_crit = resolvers.mbonus_material(2, 1),
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
			[DamageType.ACID] = resolvers.mbonus_material(20, 10),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(20, 10),
			[DamageType.FIRE] = resolvers.mbonus_material(20, 10),
			[DamageType.COLD] = resolvers.mbonus_material(20, 10),
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
		combat_atk = resolvers.mbonus_material(7, 3),
		combat_def = resolvers.mbonus_material(7, 3),
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
		on_melee_hit = {
			[DamageType.LIGHTNING] = resolvers.mbonus_material(12, 3),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(12, 3),
		},
	},
}