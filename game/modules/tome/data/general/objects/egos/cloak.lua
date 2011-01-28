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

--load("/data/general/objects/egos/charged-defensive.lua")

newEntity{
	power_source = {technique=true},
	name = "shadow ", prefix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		inc_stealth = resolvers.mbonus_material(20, 5, function(e, v) return v * 1, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "thick ", prefix=true, instant_resolve=true,
	level_range = {1, 40},
	rarity = 6,
	cost = 7,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus_material(20, 10, function(e, v) return v * 0.15 end)},
	},
}

newEntity{
	power_source = {technique=true},
	name = "plush ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 7,
	wielder = {
		combat_armor = resolvers.mbonus_material(8, 5, function(e, v) return v * 1 end),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of Eldoral", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 10,
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 1, function(e, v) return v * 3 end),
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 1, function(e, v) return v * 3 end),
			},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the Shaloren", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 10,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(3, 1, function(e, v) return v * 3 end),
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 1, function(e, v) return v * 3 end),
			},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of Iron Throne", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 10,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 1, function(e, v) return v * 3 end),
			[Stats.STAT_CON] = resolvers.mbonus_material(3, 1, function(e, v) return v * 3 end),
			},
	},
}

newEntity{
	power_source = {technique=true},
	name = "oiled ", prefix=true, instant_resolve=true,
	level_range = {1, 40},
	rarity = 6,
	cost = 7,
	wielder = {
		resists={[DamageType.ACID] = resolvers.mbonus_material(15, 10, function(e, v) return v * 0.15 end)},
	},
}


newEntity{
	power_source = {nature=true},
	name = " of fog", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 18,
	cost = 25,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(15, 10, function(e, v) return v * 0.15 end),
			[DamageType.LIGHT] = resolvers.mbonus_material(15, 10, function(e, v) return v * 0.15 end),
		},
		confusion_immune = -0.2,
		combat_def = resolvers.mbonus_material(6, 4, function(e, v) return v * 1 end),
		lite = -1,
		inc_stealth = resolvers.mbonus_material(10, 5, function(e, v) return v * 1, v end),
	},
}


newEntity{
	power_source = {nature=true},
	name = " of resilience", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		max_life=resolvers.mbonus_material(30, 30, function(e, v) return v * 0.1 end),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of stability", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
		knockback_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "enveloping ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_def = resolvers.mbonus_material(4, 4, function(e, v) return v * 1 end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of sorcery", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 16,
	cost = 50,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(2, 2, function(e, v) return v * 3 end),
			[Stats.STAT_WIL] = resolvers.mbonus_material(2, 2, function(e, v) return v * 3 end),
			[Stats.STAT_CUN] = resolvers.mbonus_material(2, 2, function(e, v) return v * 3 end),
			},
		combat_spellcrit = resolvers.mbonus_material(3, 3, function(e, v) return v * 0.4 end),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of implacability", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 16,
	cost = 50,
	wielder = {
		pin_immune = resolvers.mbonus_material(3, 2, function(e, v) v=v/10 return v * 8, v end),
		knockback_immune = resolvers.mbonus_material(3, 2, function(e, v) v=v/10 return v * 8, v end),
		confusion_immune = resolvers.mbonus_material(3, 2, function(e, v) v=v/10 return v * 8, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "restorative ", prefix=true, instant_resolve=true,
	level_range = {35, 50},
	greater_ego = true,
	rarity = 18,
	cost = 60,
	wielder = {
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
		cut_immune = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return v * 8, v end),
		life_regen = resolvers.mbonus_material(10, 5, function(e, v) v=v/10 return v * 10, v end),
		poison_immune = resolvers.mbonus_material(10, 10, function(e, v) return v * 0.15, v/100 end),

	},
}

newEntity{
	power_source = {technique=true},
	name = "regal ", prefix=true, instant_resolve=true,
	level_range = {15, 50},
	greater_ego = true,
	rarity = 15,
	cost = 20,
	wielder = {
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(2, 2, function(e, v) return v * 3 end),
			[Stats.STAT_CUN] = resolvers.mbonus_material(2, 2, function(e, v) return v * 3 end),
			},
		silence_immune = resolvers.mbonus_material(3, 2, function(e, v) v=v/10 return v * 8, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "wyrmwaxed ", prefix=true, instant_resolve=true,
	level_range = {35, 50},
	greater_ego = true,
	rarity = 18,
	cost = 60,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end),
			[DamageType.FIRE] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end),
			[DamageType.COLD] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end),
		},
	},
}
