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

--load("/data/general/objects/egos/charged-defensive.lua")

newEntity{
	power_source = {technique=true},
	name = "shadow ", prefix=true, instant_resolve=true,
	keywords = {shadow=true},
	level_range = {20, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		inc_stealth = resolvers.mbonus_material("inc_stealth"),
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
		resists={[DamageType.COLD] = resolvers.mbonus_material("resists")},
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
		combat_armor = resolvers.mbonus_material("combat_armor"),
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
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats", 0.5),
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats", 0.5),
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
			[Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats", 0.5),
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats", 0.5),
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
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats", 0.5),
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats", 0.5),
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
		resists={[DamageType.ACID] = resolvers.mbonus_material("resists")},
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
			[DamageType.FIRE] = resolvers.mbonus_material("resists"),
			[DamageType.LIGHT] = resolvers.mbonus_material("resists"),
		},
		confusion_immune = resolvers.mbonus_material("immunity", -1),
		combat_def = resolvers.mbonus_material("combat_def"),
		lite = -1,
		inc_stealth = resolvers.mbonus_material("inc_stealth"),
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
		max_life=resolvers.mbonus_material("max_life"),
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
		stun_immune = resolvers.mbonus_material("immunity"),
		knockback_immune = resolvers.mbonus_material("immunity"),
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
		combat_def = resolvers.mbonus_material("combat_def"),
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
		fatigue = resolvers.mbonus_material("fatigue"),
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
			[Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats", 0.5),
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats", 0.5),
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats", 0.5),
			},
		combat_spellcrit = resolvers.mbonus_material("combat_spellcrit"),
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
		pin_immune = resolvers.mbonus_material("immunity"),
		knockback_immune = resolvers.mbonus_material("immunity"),
		confusion_immune = resolvers.mbonus_material("immunity"),
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
		healing_factor = resolvers.mbonus_material("healing_factor"),
		--cut_immune = resolvers.mbonus_material("immunity"),
		life_regen = resolvers.mbonus_material("life_regen"),
		poison_immune = resolvers.mbonus_material("immunity"),

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
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
			},
		silence_immune = resolvers.mbonus_material("immunity"),
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
			[DamageType.ACID] = resolvers.mbonus_material("resists"),
			[DamageType.LIGHTNING] = resolvers.mbonus_material("resists"),
			[DamageType.FIRE] = resolvers.mbonus_material("resists"),
			[DamageType.COLD] = resolvers.mbonus_material("resists"),
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
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
		},
		combat_spellresist = resolvers.mbonus_material("save", -1),
		stamina_regen = resolvers.mbonus_material("stamina_regen", -1),
		mana_regen = resolvers.mbonus_material("mana_regen", -1),
		talents_types_mastery = {
			["technique/combat-training"] = resolvers.mbonus_material("talent_types_mastery"),
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
		blind_immune = resolvers.mbonus_material("immunity"),
		confusion_immune = resolvers.mbonus_material("immunity"),
		combat_mentalresist = resolvers.mbonus_material("save"),
		combat_physresist = resolvers.mbonus_material("save"),
		combat_spellresist = resolvers.mbonus_material("save"),
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
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
		},
		combat_mentalresist = resolvers.mbonus_material("save"),
		combat_physresist = resolvers.mbonus_material("save"),
		combat_spellresist = resolvers.mbonus_material("save"),
		max_life = resolvers.mbonus_material("max_life"),
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
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
		},
		combat_atk = resolvers.mbonus_material("combat_atk"),
		combat_apr = resolvers.mbonus_material("combat_apr"),
	},
}
--[=[
newEntity{
	power_source = {nature=true},
	name = "parasitic ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats", -2),
		},
		poison_immune = resolvers.mbonus_material("immunity"),
		resource_leech_chance = resolvers.mbonus_material("resource_leech_chance"),
		resource_leech_value = resolvers.mbonus_material("resource_leech_value"),
	},
}
]=]
newEntity{
	power_source = {technique=true},
	name = " of the guardian", suffix=true, instant_resolve=true,
	keywords = {guardian=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material("save"),
		combat_physresist = resolvers.mbonus_material("save"),
		combat_spellresist = resolvers.mbonus_material("save"),
		combat_armor = resolvers.mbonus_material("combat_armor"),
		combat_def = resolvers.mbonus_material("combat_def"),
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
		max_mana = resolvers.mbonus_material("max_mana"),
		combat_spellpower = resolvers.mbonus_material("combat_spellpower"),
		combat_spellcrit = resolvers.mbonus_material("combat_spellcrit"),
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
		disarm_immune = resolvers.mbonus_material("immunity"),
		--confusion_immune = resolvers.mbonus_material("immunity"),
		combat_physcrit = resolvers.mbonus_material("combat_physcrit"),
		combat_dam = resolvers.mbonus_material("combat_dam"),
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
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_BLINDING_SPEED, level = 3, power = 80 },
	wielder = {
		max_life = resolvers.mbonus_material("max_life"),
		fatigue = resolvers.mbonus_material("fatigue"),
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
		--combat_critical_power = resolvers.mbonus_material("combat_critical_power"),
		combat_atk = resolvers.mbonus_material("combat_atk"),
		combat_apr = resolvers.mbonus_material("combat_apr"),
		inc_stealth = resolvers.mbonus_material("inc_stealth"),
	},
}