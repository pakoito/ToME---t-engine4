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

--load("/data/general/objects/egos/charged-defensive.lua")

newEntity{
	power_source = {technique=true},
	name = "shadow ", prefix=true, instant_resolve=true,
	keywords = {shadow=true},
	level_range = {20, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		inc_stealth = resolvers.mbonus_material(20, 5),
	},
}

newEntity{
	power_source = {technique=true},
	name = "thick ", prefix=true, instant_resolve=true,
	keywords = {thick=true},
	level_range = {1, 40},
	rarity = 6,
	cost = 7,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus_material(20, 10)},
	},
}

newEntity{
	power_source = {technique=true},
	name = "plush ", prefix=true, instant_resolve=true,
	keywords = {plush=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 7,
	wielder = {
		combat_armor = resolvers.mbonus_material(8, 5),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of Eldoral", suffix=true, instant_resolve=true,
	keywords = {eldoral=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 10,
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 1),
			},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the Shaloren", suffix=true, instant_resolve=true,
	keywords = {shaloren=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 10,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 1),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of Iron Throne", suffix=true, instant_resolve=true,
	keywords = {['iron.throne']=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 10,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_CON] = resolvers.mbonus_material(3, 1),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "oiled ", prefix=true, instant_resolve=true,
	keywords = {oiled=true},
	level_range = {1, 40},
	rarity = 6,
	cost = 7,
	wielder = {
		resists={[DamageType.ACID] = resolvers.mbonus_material(15, 10)},
	},
}


newEntity{
	power_source = {nature=true},
	name = " of fog", suffix=true, instant_resolve=true,
	keywords = {fog=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 25,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(15, 10),
			[DamageType.LIGHT] = resolvers.mbonus_material(15, 10),
		},
		combat_def = resolvers.mbonus_material(6, 4),
		lite = -1,
		inc_stealth = resolvers.mbonus_material(10, 5),
	},
}


newEntity{
	power_source = {nature=true},
	name = " of resilience", suffix=true, instant_resolve=true,
	keywords = {resilience=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		max_life=resolvers.mbonus_material(30, 30),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of stability", suffix=true, instant_resolve=true,
	keywords = {stablity=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		knockback_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "enveloping ", prefix=true, instant_resolve=true,
	keywords = {enveloping=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_def = resolvers.mbonus_material(4, 4),
	},
}

newEntity{
	power_source = {technique=true},
	name = "lightening ", prefix=true, instant_resolve=true,
	keywords = {lightening=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		fatigue = resolvers.mbonus_material(5, 2, function(e, v) return 0, -v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of sorcery", suffix=true, instant_resolve=true,
	keywords = {sorcery=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 50,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(2, 2),
			[Stats.STAT_WIL] = resolvers.mbonus_material(2, 2),
			[Stats.STAT_CUN] = resolvers.mbonus_material(2, 2),
			},
		combat_spellcrit = resolvers.mbonus_material(3, 3),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of implacability", suffix=true, instant_resolve=true,
	keywords = {implacable=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 50,
	wielder = {
		pin_immune = resolvers.mbonus_material(3, 2, function(e, v) v=v/10 return 0, v end),
		knockback_immune = resolvers.mbonus_material(3, 2, function(e, v) v=v/10 return 0, v end),
		confusion_immune = resolvers.mbonus_material(3, 2, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "restorative ", prefix=true, instant_resolve=true,
	keywords = {restorative=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 60,
	wielder = {
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		cut_immune = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return 0, v end),
		life_regen = resolvers.mbonus_material(10, 5, function(e, v) v=v/10 return 0, v end),
		poison_immune = resolvers.mbonus_material(10, 10, function(e, v) return 0, v/100 end),

	},
}

newEntity{
	power_source = {technique=true},
	name = "regal ", prefix=true, instant_resolve=true,
	keywords = {regal=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 20,
	wielder = {
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(2, 2),
			[Stats.STAT_MAG] = resolvers.mbonus_material(2, 2),
		},
		silence_immune = resolvers.mbonus_material(3, 2, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "wyrmwaxed ", prefix=true, instant_resolve=true,
	keywords = {wyrmwaxed=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 60,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(5, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(5, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(5, 5),
			[DamageType.COLD] = resolvers.mbonus_material(5, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "battlemaster's ", prefix=true, instant_resolve=true,
	keywords = {battlemaster=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 80,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(5, 1),
			[Stats.STAT_DEX] = resolvers.mbonus_material(5, 1),
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		combat_spellresist = resolvers.mbonus_material(20, 10, function(e, v) return 0, -v end),
		stamina_regen = resolvers.mbonus_material(12, 3, function(e, v) v=v/10 return 0, -v end),
		mana_regen = resolvers.mbonus_material(50, 10, function(e, v) v=v/100 return 0, -v end),
		talents_types_mastery = {
			["technique/combat-training"] = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return 0, v end),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "spellcowled ", prefix=true, instant_resolve=true,
	keywords = {spellcowled=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		blind_immune = resolvers.mbonus_material(10, 5, function(e, v) v=v/100 return 0, v end),
		confusion_immune = resolvers.mbonus_material(10, 5, function(e, v) v=v/100 return 0, v end),
		combat_mentalresist = resolvers.mbonus_material(4, 1),
		combat_physresist = resolvers.mbonus_material(4, 1),
		combat_spellresist = resolvers.mbonus_material(4, 1),
	},
}

newEntity{
	power_source = {technique=true},
	name = "marshal's ", prefix=true, instant_resolve=true,
	keywords = {marshal=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(5, 1),
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		combat_mentalresist = resolvers.mbonus_material(4, 1),
		combat_physresist = resolvers.mbonus_material(4, 1),
		combat_spellresist = resolvers.mbonus_material(4, 1),
		max_life = resolvers.mbonus_material(70, 40),
	},
}

newEntity{
	power_source = {technique=true},
	name = "murderer's ", prefix=true, instant_resolve=true,
	keywords = {murderer=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(5, 1),
			[Stats.STAT_CUN] = resolvers.mbonus_material(5, 1),
		},
		combat_atk = resolvers.mbonus_material(7, 3),
		combat_apr = resolvers.mbonus_material(7, 3),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of the guardian", suffix=true, instant_resolve=true,
	keywords = {guardian=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		combat_physresist = resolvers.mbonus_material(10, 5),
		combat_spellresist = resolvers.mbonus_material(10, 5),
		combat_armor = resolvers.mbonus_material(7, 3),
		combat_def = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of conjuring", suffix=true, instant_resolve=true,
	keywords = {conjuring=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 70,
	wielder = {
		max_mana = resolvers.mbonus_material(80, 20),
		combat_spellpower = resolvers.mbonus_material(7, 3),
		combat_spellcrit = resolvers.mbonus_material(3, 3),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of warlust", suffix=true, instant_resolve=true,
	keywords = {warlust=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		disarm_immune = resolvers.mbonus_material(15, 5, function(e, v) v=v/100 return 0, v end),
		confusion_immune = resolvers.mbonus_material(15, 5, function(e, v) v=v/100 return 0, v end),
		combat_physcrit = resolvers.mbonus_material(4, 1),
		combat_dam = resolvers.mbonus_material(4, 1),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of the hunt", suffix=true, instant_resolve=true,
	keywords = {hunt=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	resolvers.charmt(Talents.T_BLINDING_SPEED, {2,3,4}, 45),
	wielder = {
		max_life = resolvers.mbonus_material(70, 40),
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return 0, -v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of backstabbing", suffix=true, instant_resolve=true,
	keywords = {backstab=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 70,
	wielder = {
		combat_critical_power = resolvers.mbonus_material(30, 10),
		combat_atk = resolvers.mbonus_material(10, 5),
		combat_apr = resolvers.mbonus_material(10, 5),
		inc_stealth = resolvers.mbonus_material(10, 5),
	},
}