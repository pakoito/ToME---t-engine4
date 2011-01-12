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

local Stats = require "engine.interface.ActorStats"
local DamageType = require "engine.DamageType"

--load("/data/general/objects/egos/charged-attack.lua")
--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	name = " of see invisible", suffix=true,
	level_range = {1, 20},
	rarity = 4,
	cost = 2,
	wielder = {
		see_invisible = resolvers.mbonus_material(20, 5, function(e, v) return v * 0.2 end),
	},
}

newEntity{
	name = " of regeneration (#REGEN#)", suffix=true,
	level_range = {10, 20},
	rarity = 10,
	cost = 8,
	wielder = {
		life_regen = resolvers.mbonus_material(30, 5, function(e, v) v=v/10 return v * 10, v end),
	},
}

newEntity{
	name = " of mana (#REGEN#)", suffix=true,
	level_range = {10, 20},
	rarity = 8,
	cost = 3,
	wielder = {
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}

newEntity{
	name = " of fire (#RESIST#)", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.FIRE] = resolvers.mbonus_material(10, 10, function(e, v) return v * 0.8 end) },
		resists = {[DamageType.FIRE] = resolvers.genericlast(function(e) return e.wielder.inc_damage[engine.DamageType.FIRE] end) },
	},
}

newEntity{
	name = " of frost (#RESIST#)", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.COLD] = resolvers.mbonus_material(10, 10, function(e, v) return v * 0.8 end) },
		resists = {[DamageType.COLD] = resolvers.genericlast(function(e) return e.wielder.inc_damage[engine.DamageType.COLD] end) },
	},
}

newEntity{
	name = " of nature (#RESIST#)", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.NATURE] = resolvers.mbonus_material(10, 10, function(e, v) return v * 0.8 end) },
		resists = {[DamageType.NATURE] = resolvers.genericlast(function(e) return e.wielder.inc_damage[engine.DamageType.NATURE] end) },
	},
}

newEntity{
	name = " of lightning (#RESIST#)", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.LIGHTNING] = resolvers.mbonus_material(10, 10, function(e, v) return v * 0.8 end) },
		resists = {[DamageType.LIGHTNING] = resolvers.genericlast(function(e) return e.wielder.inc_damage[engine.DamageType.LIGHTNING] end) },
	},
}

newEntity{
	name = " of corrosion (#RESIST#)", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.ACID] = resolvers.mbonus_material(10, 10, function(e, v) return v * 0.8 end) },
		resists = {[DamageType.ACID] = resolvers.genericlast(function(e) return e.wielder.inc_damage[engine.DamageType.ACID] end) },
	},
}

newEntity{
	name = " of blight (#RESIST#)", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.BLIGHT] = resolvers.mbonus_material(10, 10, function(e, v) return v * 0.8 end) },
		resists = {[DamageType.BLIGHT] = resolvers.genericlast(function(e) return e.wielder.inc_damage[engine.DamageType.BLIGHT] end) },
	},
}

newEntity{
	name = " of massacre (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.8 end) },
	},
}

newEntity{ define_as = "RING_ARCANE_POWER",
	name = " of arcane power (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.ARCANE] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.8 end) },
	},
}

newEntity{
	name = "savior's ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		combat_physresist = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		combat_spellresist = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
	},
}

newEntity{
	name = "brawler's ", prefix=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(8, 2, function(e, v) return v * 3 end) },
		combat_def = resolvers.genericlast(function(e) return e.wielder.inc_stats[engine.interface.ActorStats.STAT_STR] end),
	},
}

newEntity{
	name = "titan's ", prefix=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = resolvers.mbonus_material(8, 2, function(e, v) return v * 3 end) },
		combat_physresist = resolvers.genericlast(function(e) return e.wielder.inc_stats[engine.interface.ActorStats.STAT_CON] end),
	},
}

newEntity{
	name = "duelist's ", prefix=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material(8, 2, function(e, v) return v * 3 end) },
		combat_atk = resolvers.genericlast(function(e) return e.wielder.inc_stats[engine.interface.ActorStats.STAT_DEX] end),
	},
}

newEntity{ define_as = "RING_MAGIC",
	name = "wizard's ", prefix=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(8, 2, function(e, v) return v * 3 end) },
		combat_spellresist = resolvers.genericlast(function(e) return e.wielder.inc_stats[engine.interface.ActorStats.STAT_MAG] end),
	},
}

newEntity{
	name = "mule's ", prefix=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		max_encumber = resolvers.mbonus_material(20, 20, function(e, v) return v * 0.4, v end),
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return v * 1, -v end),
	},
}

newEntity{
	name = "sneakthief's ", prefix=true, instant_resolve=true,
	level_range = {15, 50},
	greater_ego = true,
	rarity = 12,
	cost = 20,
	wielder = {
		lite = -2,	
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(6, 4, function(e, v) return v * 3 end),
			[Stats.STAT_CUN] = resolvers.mbonus_material(6, 4, function(e, v) return v * 3 end),
	},
	},
}

newEntity{
	name = "gladiator's ", prefix=true, instant_resolve=true,
	level_range = {15, 50},
	greater_ego = true,
	rarity = 12,
	cost = 20,
	wielder = {
		combat_dam = resolvers.mbonus_material(10, 5, function(e, v) return v * 3 end),
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(6, 4, function(e, v) return v * 3 end),
			[Stats.STAT_CON] = resolvers.mbonus_material(6, 4, function(e, v) return v * 3 end),
	},
	},
}

newEntity{
	name = "conjurer's ", prefix=true, instant_resolve=true,
	level_range = {15, 50},
	greater_ego = true,
	rarity = 12,
	cost = 20,
	wielder = {
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return v * 80, v end),
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(4, 4, function(e, v) return v * 3 end),
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 4, function(e, v) return v * 3 end),
			},	
	},
}

newEntity{
	name = " of tenacity", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 12,
	cost = 50,
	wielder = {
		pin_immune = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return v * 8, v end),
		knockback_immune = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return v * 8, v end),
		disarm_immune = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return v * 8, v end),	
	},
}


newEntity{
	name = " of evocation", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 12,
	cost = 50,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(3, 3, function(e, v) return v * 0.8 end),
		combat_spellcrit = resolvers.mbonus_material(3, 3, function(e, v) return v * 0.4 end),
		inc_damage = { [DamageType.ARCANE] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.8 end) },	
	},
}

newEntity{
	name = " of life", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 12,
	cost = 50,
	wielder = {	
		max_life=resolvers.mbonus_material(60, 40, function(e, v) return v * 0.1 end),
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return v * 10, v end),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),	

	},
}
